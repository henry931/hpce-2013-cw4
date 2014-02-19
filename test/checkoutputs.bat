cd C:\Users\Henry\Dropbox\HPC\Coursework\CW4\hpce-2013-cw4\bin

set HPCE_SELECT_DEVICE=0
set HPCE_CL_SRC_DIR=../src/hgp10
make_world 128 | step_world 0.1 10000 | render_world dump_step_world.bmp
make_world 128 | step_world_v1_lambda 0.1 10000 | render_world dump_step_world_v1_lambda.bmp
make_world 128 | step_world_v2_function 0.1 10000 | render_world dump_step_world_v2_function.bmp
make_world 128 | step_world_v3_opencl 0.1 10000 | render_world dump_step_world_v3_opencl.bmp
make_world 128 | step_world_v4_double_buffered 0.1 10000 | render_world dump_step_world_v4_double_buffered.bmp

echo "step_world vs step_world_v1_lambda"
fc dump_step_world.bmp dump_step_world_v1_lambda.bmp
echo "step_world vs step_world_v2_function"
fc dump_step_world.bmp dump_step_world_v2_function.bmp
echo "step_world vs step_world_v3_opencl"
fc dump_step_world.bmp dump_step_world_v3_opencl.bmp
echo "step_world vs step_world_v4_double_buffered"
fc dump_step_world.bmp dump_step_world_v4_double_buffered.bmp
echo "step_world_v3_opencl vs step_world_v4_double_buffered"
fc dump_step_world_v3_opencl.bmp dump_step_world_v4_double_buffered.bmp

pause