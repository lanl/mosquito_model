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
conda install -c conda-forge r r-lggger
conda install -c conda-forge r r-yaml
conda install -c conda-forge r r-sp
conda install -c conda-forge r r-rgdal
conda install -c conda-forge r r-tidyverse
```

Each one of these `conda install` will ask you to confirm y/n to proceed to install after the environment solve if you want to stop this add a `-y` or `--yes` to auto proceed. 

## Running the model 
```
conda activate /projects/cimmid/miniconda3/mosq-R
bash run_mosq_toy.sh
```
