cd C:\Users\Henry\Dropbox\HPC\Coursework\CW4\hpce-2013-cw4\bin

.\make_world 1024 > world.txt

$env:HPCE_CL_SRC_DIR="../src/hgp10"

# make_world dimensions propagation_constant
# step_world time_step number_of_steps
Write-Host "Timing step_world"
Measure-Command {cat .\world.txt | .\step_world 0.1 1000 > $null}
Write-Host "Timing step_world_v1_lambda"
Measure-Command {cat .\world.txt | .\step_world_v1_lambda 0.1 1000 > $null}
Write-Host "Timing step_world_v2_function"
Measure-Command {cat .\world.txt | .\step_world_v2_function 0.1 1000 > $null}

$env:HPCE_SELECT_DEVICE="0"
Write-Host "Timing step_world_v3_opencl with GPU"
Measure-Command {cat .\world.txt | .\step_world_v3_opencl 0.1 1000 > $null}

$env:HPCE_SELECT_DEVICE="1"
Write-Host "Timing step_world_v3_opencl with CPU"
Measure-Command {cat .\world.txt | .\step_world_v3_opencl 0.1 1000 > $null}

$env:HPCE_SELECT_DEVICE="0"
Write-Host "Timing step_world_v4_double_buffered with GPU"
Measure-Command {cat .\world.txt | .\step_world_v4_double_buffered 0.1 1000 > $null}

$env:HPCE_SELECT_DEVICE="1"
Write-Host "Timing step_world_v4_double_buffered with CPU"
Measure-Command {cat .\world.txt | .\step_world_v4_double_buffered 0.1 1000 > $null}

pause