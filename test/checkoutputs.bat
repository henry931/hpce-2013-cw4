cd C:\Users\Henry\Dropbox\HPC\Coursework\CW4\hpce-2013-cw4\bin

make_world.exe 100 0.1 | step_world 0.1 10000 | render_world dump_step_world.bmp
make_world.exe 100 0.1 | step_world_v1_lambda 0.1 10000 | render_world dump_step_world_v1_lambda.bmp
make_world.exe 100 0.1 | step_world_v2_function 0.1 10000 | render_world dump_step_world_v2_function.bmp
make_world.exe 100 0.1 | step_world_v3_opencl 0.1 10000 | render_world dump_step_world_v3_opencl.bmp

fc dump_step_world.bmp dump_step_world_v1_lambda.bmp
fc dump_step_world.bmp dump_step_world_v2_function.bmp
fc dump_step_world.bmp dump_step_world_v3_opencl.bmp
pause