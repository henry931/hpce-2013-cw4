cd C:\Users\Henry\Dropbox\HPC\Coursework\CW4\hpce-2013-cw4\bin

$env:HPCE_CL_SRC_DIR="../src/hgp10"

Measure-Command {.\make_world 100 0.1 | .\step_world 0.1 10000 > $null}
Measure-Command {.\make_world 100 0.1 | .\step_world_v1_lambda 0.1 10000 > $null}
Measure-Command {.\make_world 100 0.1 | .\step_world_v2_function 0.1 10000 > $null}

$env:HPCE_SELECT_DEVICE="0"
Measure-Command {.\make_world 100 0.1 | .\step_world_v3_opencl 0.1 10000 > $null}

$env:HPCE_SELECT_DEVICE="1"
Measure-Command {.\make_world 100 0.1 | .\step_world_v3_opencl 0.1 10000 > $null}

pause