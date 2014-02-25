cd C:\Users\Henry\Dropbox\HPC\Coursework\CW4\hpce-2013-cw4\bin

$env:WORLD_SIZE=1024
$env:PROP_CONSTANT=0.1
$env:TIME_STEP=0.1
$env:NUM_STEPS=100000

echo "World size is $env:WORLD_SIZE" > ..\testscripts\timeoutputsdump.txt
echo "Conductivity constant is $env:PROP_CONSTANT" >> ..\testscripts\timeoutputsdump.txt
echo "Step time is $env:TIME_STEP" >> ..\testscripts\timeoutputsdump.txt
echo "Number of steps is $env:NUM_STEPS" >> ..\testscripts\timeoutputsdump.txt

.\make_world $env:WORLD_SIZE $env:PROP_CONSTANT > world.txt

$env:HPCE_CL_SRC_DIR="../src/hgp10"

# make_world dimensions propagation_constant
# step_world time_step number_of_steps

echo "Timing step_world" >> ..\testscripts\timeoutputsdump.txt
Measure-Command {cat .\world.txt | .\step_world $env:TIME_STEP $env:NUM_STEPS > $null} >> ..\testscripts\timeoutputsdump.txt
echo "Timing step_world_v1_lambda" >> ..\testscripts\timeoutputsdump.txt
Measure-Command {cat .\world.txt | .\step_world_v1_lambda $env:TIME_STEP $env:NUM_STEPS > $null} >> ..\testscripts\timeoutputsdump.txt
echo "Timing step_world_v2_function" >> ..\testscripts\timeoutputsdump.txt
Measure-Command {cat .\world.txt | .\step_world_v2_function $env:TIME_STEP $env:NUM_STEPS > $null} >> ..\testscripts\timeoutputsdump.txt

$env:HPCE_SELECT_DEVICE="0"
echo "Timing step_world_v3_opencl with GPU" >> ..\testscripts\timeoutputsdump.txt
Measure-Command {cat .\world.txt | .\step_world_v3_opencl $env:TIME_STEP $env:NUM_STEPS > $null} >> ..\testscripts\timeoutputsdump.txt

$env:HPCE_SELECT_DEVICE="1"
echo "Timing step_world_v3_opencl with CPU" >> ..\testscripts\timeoutputsdump.txt
Measure-Command {cat .\world.txt | .\step_world_v3_opencl $env:TIME_STEP $env:NUM_STEPS > $null} >> ..\testscripts\timeoutputsdump.txt

$env:HPCE_SELECT_DEVICE="0"
echo "Timing step_world_v4_double_buffered with GPU" >> ..\testscripts\timeoutputsdump.txt
Measure-Command {cat .\world.txt | .\step_world_v4_double_buffered $env:TIME_STEP $env:NUM_STEPS > $null} >> ..\testscripts\timeoutputsdump.txt

$env:HPCE_SELECT_DEVICE="1"
echo "Timing step_world_v4_double_buffered with CPU" >> ..\testscripts\timeoutputsdump.txt
Measure-Command {cat .\world.txt | .\step_world_v4_double_buffered $env:TIME_STEP $env:NUM_STEPS > $null} >> ..\testscripts\timeoutputsdump.txt

$env:HPCE_SELECT_DEVICE="0"
echo "Timing step_world_v5_packed_properties with GPU" >> ..\testscripts\timeoutputsdump.txt
Measure-Command {cat .\world.txt | .\step_world_v5_packed_properties $env:TIME_STEP $env:NUM_STEPS > $null} >> ..\testscripts\timeoutputsdump.txt

$env:HPCE_SELECT_DEVICE="1"
echo "Timing step_world_v5_packed_properties with CPU" >> ..\testscripts\timeoutputsdump.txt
Measure-Command {cat .\world.txt | .\step_world_v5_packed_properties $env:TIME_STEP $env:NUM_STEPS > $null} >> ..\testscripts\timeoutputsdump.txt

echo "Testing Complete" >> ..\testscripts\timeoutputsdump.txt