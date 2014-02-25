// Otherwise minwindef.h runs naughty macros
#define NOMINMAX
#include "heat.hpp"
#include <stdexcept>
#include <cmath>
#include <cstdint>
#include <memory>
#include <cstdio>
#include <string>
#include <fstream>
#include <streambuf>

#define __CL_ENABLE_EXCEPTIONS 
#include "CL/cl.hpp"

namespace hpce{

	namespace hgp10{

		//! Reference world stepping program
		/*! \param dt Amount to step the world by.  Note that large steps will be unstable.
		\param n Number of times to step the world
		\note Overall time increment will be n*dt
		*/

		// Get CL Code
		std::string LoadSource(const char *fileName)
		{
			// Don't forget to change your_login here
			std::string baseDir="src/hgp10";
			if(getenv("HPCE_CL_SRC_DIR")){
				baseDir=getenv("HPCE_CL_SRC_DIR");
			}

			std::string fullName=baseDir+"/"+fileName;

			std::ifstream src(fullName, std::ios::in | std::ios::binary);
			if(!src.is_open())
				throw std::runtime_error("LoadSource : Couldn't load cl file from '"+fullName+"'.");

			return std::string(
				(std::istreambuf_iterator<char>(src)), // Node the extra brackets.
				std::istreambuf_iterator<char>()
				);
		}

		void StepWorldV3OpenCL(world_t &world, float dt, unsigned n)
		{
			// Get list of platforms
			std::vector<cl::Platform> platforms;

			cl::Platform::get(&platforms);
			if(platforms.size()==0)
				throw std::runtime_error("No OpenCL platforms found.");

			// Print names of platforms
			std::cerr<<"Found "<<platforms.size()<<" platforms\n";
			for(unsigned i=0;i<platforms.size();i++){
				std::string vendor=platforms[0].getInfo<CL_PLATFORM_VENDOR>();
				std::cerr<<"  Platform "<<i<<" : "<<vendor<<"\n";
			}

			// Add platform selection switch
			int selectedPlatform=0;
			if(getenv("HPCE_SELECT_PLATFORM")){
				selectedPlatform=atoi(getenv("HPCE_SELECT_PLATFORM"));
			}
			std::cerr<<"Choosing platform "<<selectedPlatform<<"\n";
			cl::Platform platform=platforms.at(selectedPlatform);

			// Get devices
			std::vector<cl::Device> devices;
			platform.getDevices(CL_DEVICE_TYPE_ALL, &devices);  
			if(devices.size()==0){
				throw std::runtime_error("No opencl devices found.\n");
			}

			std::cerr<<"Found "<<devices.size()<<" devices\n";
			for(unsigned i=0;i<devices.size();i++){
				std::string name=devices[i].getInfo<CL_DEVICE_NAME>();
				std::cerr<<"  Device "<<i<<" : "<<name<<"\n";
			}

			// Add device selection switch
			int selectedDevice=0;
			if(getenv("HPCE_SELECT_DEVICE")){
				selectedDevice=atoi(getenv("HPCE_SELECT_DEVICE"));
			}
			std::cerr<<"Choosing device "<<selectedDevice<<"\n";
			cl::Device device=devices.at(selectedDevice);

			// Create OpenCL context
			cl::Context context(devices);

			// Get source cl file
			std::string kernelSource=LoadSource("step_world_v3_kernel.cl");

			cl::Program::Sources sources;   // A vector of (data,length) pairs
			sources.push_back(std::make_pair(kernelSource.c_str(), kernelSource.size()+1)); // push on our single string

			cl::Program program(context, sources);
			try{
				program.build(devices);
			}catch(...){
				for(unsigned i=0;i<devices.size();i++){
					std::cerr<<"Log for device "<<devices[i].getInfo<CL_DEVICE_NAME>()<<":\n\n";
					std::cerr<<program.getBuildInfo<CL_PROGRAM_BUILD_LOG>(devices[i])<<"\n\n";
				}
				throw;
			}

			// Allocate buffers
			size_t cbBuffer=4*world.w*world.h;
			cl::Buffer buffProperties(context, CL_MEM_READ_ONLY, cbBuffer);
			cl::Buffer buffState(context, CL_MEM_READ_ONLY, cbBuffer);
			cl::Buffer buffBuffer(context, CL_MEM_WRITE_ONLY, cbBuffer);

			// Set the kernel parameters
			cl::Kernel kernel(program, "kernel_xy");

			unsigned w=world.w, h=world.h;

			float outer=world.alpha*dt;		// We spread alpha to other cells per time
			float inner=1-outer/4;				// Anything that doesn't spread stays

			// Bind parameters to the kernel
			kernel.setArg(0, buffState);
			kernel.setArg(1, buffBuffer);
			kernel.setArg(2, inner);
			kernel.setArg(3, outer);
			kernel.setArg(4, buffProperties);

			// Create command queue
			cl::CommandQueue queue(context, device);

			// Copy over properties buffer to GPU
			queue.enqueueWriteBuffer(buffProperties, CL_TRUE, 0, cbBuffer, &world.properties[0]);


			// This is our temporary working space
			std::vector<float> buffer(w*h);

			////////////////////////////////////// Main Loop /////////////////////////////////////////////
			for(unsigned t=0;t<n;t++){

				// Copy current state over to GPU
				cl::Event evCopiedState;
				queue.enqueueWriteBuffer(buffState, CL_FALSE, 0, cbBuffer, &world.state[0], NULL, &evCopiedState);

				// Set up iteration space
				cl::NDRange offset(0, 0);               // Always start iterations at x=0, y=0
				cl::NDRange globalSize(w, h);			// Global size must match the original loops
				cl::NDRange localSize=cl::NullRange;    // We don't care about local size

				// Establish dependencies and produce event evExecutedKernel
				std::vector<cl::Event> kernelDependencies(1, evCopiedState);
				cl::Event evExecutedKernel;
				queue.enqueueNDRangeKernel(kernel, offset, globalSize, localSize, &kernelDependencies, &evExecutedKernel);

				// Copy results back after job has finished
				std::vector<cl::Event> copyBackDependencies(1, evExecutedKernel);
				queue.enqueueReadBuffer(buffBuffer, CL_TRUE, 0, cbBuffer, &buffer[0], &copyBackDependencies);

				// All cells have now been calculated and placed in buffer, so we replace
				// the old state with the new state
				std::swap(world.state, buffer);
				// Swapping rather than assigning is cheaper: just a pointer swap
				// rather than a memcpy, so O(1) rather than O(w*h)

				world.t += dt; // We have moved the world forwards in time

			} // end of for(t...
		}

	}; // namespace hgp10

}; // namepspace hpce

int main(int argc, char *argv[])
{
	float dt= (float) 0.1;
	unsigned n=1;
	bool binary=false;

	if(argc>1){
		dt=(float)strtod(argv[1], NULL);
	}
	if(argc>2){
		n=atoi(argv[2]);
	}
	if(argc>3){
		if(atoi(argv[3]))
			binary=true;
	}

	try{
		hpce::world_t world=hpce::LoadWorld(std::cin);
		std::cerr<<"Loaded world with w="<<world.w<<", h="<<world.h<<std::endl;

		std::cerr<<"Stepping by dt="<<dt<<" for n="<<n<<std::endl;
		hpce::hgp10::StepWorldV3OpenCL(world, dt, n);

		hpce::SaveWorld(std::cout, world, binary);
	}catch(const std::exception &e){
		std::cerr<<"Exception : "<<e.what()<<std::endl;
		return 1;
	}

	return 0;
}