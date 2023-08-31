# Mosquito PBM Integration Work Flow
Home of the Mosquito PBM set up for the integration workflow.  

## Running the model (single location_id run) 
If the conda environment (mosq-R) is set up in the `cimmid/miniconda3/` folder, you do not need to re-set up this environment. *If this is the first time running the model you will need to set up the conda environment. **See instructions below***

The basic comands to run the model are: 
```
conda activate /projects/cimmid/miniconda3/envs/mosq-R
bash run_mosq_toy.sh path_to_config_file location_id
```

The `path_to_config_file` can be a relative or absolute path. `location_id` should be a number matching one row of the look up table and one environmental data file. 

Currently the model is set up to run locally on the master branch at `/projects/cimmid/users/kaitlynm/mosquito-toy-model`. The config file to use is `config/mosq_config_integration_default.yaml`. Additionally the lookup table and the environmental input-data is stored at `/projects/cimmid/users/kaitlynm/mosquito-pbm-local/input-data`. 

An example run looks like: 
```
bash run_mosq_toy.sh config/mosq_config_integration_default.yaml 11653
```

## Running the model at full-scale on Chicoma
### Setting up the batch script
The file `mosquitoPopSubmissionTemplate.sh` is a template batch script. A full scale Chicoma run requires a plaintext file with *ONLY* one hpu_id on each line (see `hpus_testSlurm.txt` for an example).
The Python script `batchScriptSetup.py` reads this plaintext file and partitions it into jobs using slurm arrays. It then generates the appropriate batch script.
This script can be run with the following:
```
module load python
python batchScriptSetup.py -n <experiment_name> -m <HPU list plaintext file>
```
For example,
```
python batchScriptSetup.py -n testSlurm -m hpus_testSlurm.txt
```
This can be run with the script `reset_testrun.sh`, which also cleans the temporary files and slurm output from the previous run (it does not remove mosquito model output).

### Running the model
The template batch files currently points to the configuration file `mosq_config_integration_default_chicoma.yaml`. This config file contains example filepaths for the Chicoma system (including storing model output in scratch space).
Run `sbatch -J <experiment_name> mosquitoPopSubmission_<experiment_name>.sh` from the mosquito_pop model directory to run the model.

## Setting up the virtual environment 
With a miniconda3 instance already set up in the `/projects/cimmid/` folder all that needs to be done is setting up the mosquito model environment. For further details on setting up the miniconda3 installation, there will be forthcoming instructions provided by the infrastructure team. 

In the `/projects/cimmid/miniconda3/` folder run 
```Bash
conda create --name mosq-R python=3.8
```

Even though we are setting up an R environment we need to install a python version to solve environments and at least install mamba and the R packages

Activate the `mosq-R` environment to continue installing packages
```
conda activate /projects/cimmid/miniconda3/envs/mosq-R
``` 
You should see something like this in your terminal 
```
(mosq-R) [kaitlynm@darwin-fe1 miniconda3]$
```

Next we will install mamba for faster solving of environments (significantly faster)
```
conda install -c conda-forge mamba
```

Then the R packages can be added one by one (or in a list)
```
mamba install -c conda-forge r-essentials r-logger r-subplex r-optimr -y
```

Each one of these `conda install` will ask you to confirm y/n to proceed to install after the environment solve if you want to stop this add a `-y` or `--yes` to auto proceed. 




## Copyright
© 2022. Triad National Security, LLC. All rights reserved. C22097.
This program was produced under U.S. Government contract 89233218CNA000001 for Los Alamos National Laboratory (LANL), which is operated by Triad National Security, LLC for the U.S. Department of Energy/National Nuclear Security Administration. All rights in the program are reserved by Triad National Security, LLC, and the U.S. Department of Energy/National Nuclear Security Administration. The Government is granted for itself and others acting on its behalf a nonexclusive, paid-up, irrevocable worldwide license in this material to reproduce, prepare derivative works, distribute copies to the public, perform publicly and display publicly, and to permit others to do so.
## License
This program is open source under the BSD-3 License. Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


