cd C:\Users\Henry\Dropbox\HPC\Coursework\CW4\hpce-2013-cw4\bin

set HPCE_SELECT_DEVICE=0
set HPCE_CL_SRC_DIR=../src/hgp10

make_world.exe 100 0.1 | step_world 0.1 10000 > dump_step_world.txt
make_world.exe 100 0.1 | step_world_v1_lambda 0.1 10000 > dump_step_world_v1_lambda.txt
make_world.exe 100 0.1 | step_world_v2_function 0.1 10000 > dump_step_world_v2_function.txt
make_world.exe 100 0.1 | step_world_v3_opencl 0.1 10000 > dump_step_world_v3_opencl.txt
make_world.exe 100 0.1 | step_world_v4_double_buffered 0.1 10000 > dump_step_world_v4_double_buffered.txt

fc dump_step_world.txt dump_step_world_v1_lambda.txt
fc dump_step_world.txt dump_step_world_v2_function.txt
fc dump_step_world.txt dump_step_world_v3_opencl.txt
fc dump_step_world.txt dump_step_world_v4_double_buffered.txt

pause