cd C:\Users\Henry\Dropbox\HPC\Coursework\CW4\hpce-2013-cw4\bin

set HPCE_SELECT_DEVICE=0
set HPCE_CL_SRC_DIR=../src/hgp10
make_world 128 | step_world 0.1 10000 | render_world dump_step_world.bmp
make_world 128 | step_world_v1_lambda 0.1 10000 | render_world dump_step_world_v1_lambda.bmp
make_world 128 | step_world_v2_function 0.1 10000 | render_world dump_step_world_v2_function.bmp
make_world 128 | step_world_v3_opencl 0.1 10000 | render_world dump_step_world_v3_opencl.bmp
make_world 128 | step_world_v4_double_buffered 0.1 10000 | render_world dump_step_world_v4_double_buffered.bmp
make_world 128 | step_world_v5_packed_properties 0.1 10000 | render_world dump_step_world_v5_packed_properties.bmp

echo "step_world vs step_world_v1_lambda" > ..\testscripts\checkoutputsdump.txt
fc dump_step_world.bmp dump_step_world_v1_lambda.bmp >> ..\testscripts\checkoutputsdump.txt
echo "step_world vs step_world_v2_function" >> ..\testscripts\checkoutputsdump.txt
fc dump_step_world.bmp dump_step_world_v2_function.bmp >> ..\testscripts\checkoutputsdump.txt
echo "step_world vs step_world_v3_opencl" >> ..\testscripts\checkoutputsdump.txt
fc dump_step_world.bmp dump_step_world_v3_opencl.bmp >> ..\testscripts\checkoutputsdump.txt
echo "step_world vs step_world_v4_double_buffered" >> ..\testscripts\checkoutputsdump.txt
fc dump_step_world.bmp dump_step_world_v4_double_buffered.bmp >> ..\testscripts\checkoutputsdump.txt
echo "step_world vs step_world_v5_packed_properties" >> ..\testscripts\checkoutputsdump.txt
fc dump_step_world.bmp dump_step_world_v5_packed_properties.bmp >> ..\testscripts\checkoutputsdump.txt