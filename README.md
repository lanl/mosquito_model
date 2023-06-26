# Mosquito Toy Model
Home of the Mosquito Toy Model. Need to make it a separate repo due to underlying issues with the Mosquito PBM that will take too long to resolve. 

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

Next we will install mamba for faster solving of environments (at this point it doesn't seem necessary but may be as we add R or python packages to our model needs)
```
conda install -c conda-forge mamba
```

Then the R packages can be added one by one (or in a list)
```
conda install -c conda-forge r-lggger
conda install -c conda-forge r-yaml
conda install -c conda-forge r-sp
conda install -c conda-forge r-rgdal
conda install -c conda-forge r-tidyverse
conda install -c conda-forge r-subplex
conda install -c conda-forge r-optimr
```

Each one of these `conda install` will ask you to confirm y/n to proceed to install after the environment solve if you want to stop this add a `-y` or `--yes` to auto proceed. 

## Running the model 
```
conda activate /projects/cimmid/miniconda3/mosq-R
bash run_mosq_toy.sh
```


## Copyright
© 2022. Triad National Security, LLC. All rights reserved. C22097.
This program was produced under U.S. Government contract 89233218CNA000001 for Los Alamos National Laboratory (LANL), which is operated by Triad National Security, LLC for the U.S. Department of Energy/National Nuclear Security Administration. All rights in the program are reserved by Triad National Security, LLC, and the U.S. Department of Energy/National Nuclear Security Administration. The Government is granted for itself and others acting on its behalf a nonexclusive, paid-up, irrevocable worldwide license in this material to reproduce, prepare derivative works, distribute copies to the public, perform publicly and display publicly, and to permit others to do so.
## License
This program is open source under the BSD-3 License. Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# TEST MIRROR
