#### Run PBM on multiple locations in the integration pipeline

## Need: 
## Overall config file containing universal parameters,paths,settings for each experiment
## Look up csv with location specific parameters
## Not designed for fitting

#### Environment Set Up #### 
rm(list = ls())
library(yaml) # to read in yaml file
options("rgdal_show_exportToProj4_warnings"="none")
suppressPackageStartupMessages({
  library(sp,quietly = TRUE)
  library(rgdal,quietly = TRUE) # read geojsons
  library(logger,quietly = TRUE) # logger package
  library(tidyverse,quietly = TRUE) # Data manipulation
  library(lubridate,quietly = TRUE) # date manip
  library(stringr,quietly = TRUE) # string manip
  ## sub-processes libraries
  library(subplex,quietly = TRUE)
  library(optimr,quietly = TRUE)
})


#### Source Functions #### 
source("model_scripts/all_run_fxns.R")
source("model_scripts/mosq_param_funcs.R")
#call the function which will read in the format and observed and external data sources
# i.e. Wetness (Precip,Water Levels, etc), Temperature, and Daylight hrs 
source("model_scripts/data_import_function.R")
source("model_scripts/daylight-hrs-fxn.R")

#### Command Line Args ####
args <- commandArgs(trailingOnly = TRUE)
## For testing
# args <- c("-c", "mosquito-pbm/code/config/mosq_config_integration_default.yaml","-m", "c", "-l","11230")
## 
config_file <- args[which(grepl("-c",args))+1] ## path name must be specified
mosq_type <- args[which(grepl("-m",args))+1] ## required to specify 'culex|C|c' or 'aedes|A|a'
location_id <- args[which(grepl("-l",args))+1] ## location of the location specific lookup table

### Read in Config File ####
config_data <- yaml.load_file(config_file, eval.expr = TRUE)

#### Set Up Log File ####
log.file <- file(config_data$LOGFILE_PATH)
log_appender(appender_file(config_data$LOGFILE_PATH,append = T))


#### Read in Parameter Defaults
if (tolower(mosq_type) %in%c('culex',"c")){ ### Eventually add sub classes for both culex and aedes
  params <- config_data$PARAMETERS$CULEX$MOSQ_PARAMS
  source("model_scripts/culex_ss_test.R")
}

if (tolower(mosq_type) %in%c('aedes','a','a_aegypti')){
  params <- config_data$PARAMETERS$A_AEGPTYI$MOSQ_PARAMS
  fit_params <- config_data$PARAMETERS$A_AEGPTYI$FIT_PARAMS
  source("model_scripts/aegypti_ss_test.R")
}
N <- config_data$N_VAL
burnin <- config_data$BURNIN


#### Update Location Specific Information ####
lookup.tab <- read.csv(config_data$LOOKUP_PATH) %>% filter(hpu_id == location_id)
params[["LP_Mortality"]][["alpha1"]]  <- lookup.tab$lp_mort_alpha1
params[["LP_Mortality"]][["beta1"]]   <- lookup.tab$lp_mort_beta1
params[["Oviposition"]]               <- lookup.tab$oviposition
params[["init"]]                      <- lookup.tab$init
log_info("Complete: Location Specific parameters updated")


input.data <- data.import.hu(config_data,burnin=burnin,location_id)
observed.data <- input.data$observed
external.signal <- input.data$external

### Generate Daylighthrs information in the external data 
external.signal <- external.signal %>% 
  mutate(Daylighthrs=daylight.hrs.day(latitude=lookup.tab$centroid_y,longitude=lookup.tab$centroid_x, date=date),
         Daylighthrs = Daylighthrs-max(Daylighthrs))
log_info("Complete: Data read in")
log_info(paste0("Start: Run Mosquito Model for HU-",location_id))
if(config_data$RUN_TYPE == 'train'){ ### not functional for now
  ### trains to mosquito data provided and generates a full matched simulation to both training and testing data
  ### DO TRAINING (Must filter data to training split)
  print("this doesn't do anything yet")
  ### Then update parameters and plot full series
}else if(config_data$RUN_TYPE == 'basic'){ ### this just runs a basic run using parameters determined in the preamble
  out_all <- run_model(params, external.signal)
}
log_info(paste0("Complete: Run Mosquito Model for HU-",location_id))

write.csv(out_all,paste0(config_data$MODEL_OUTPUT_DIR,"pbm_out_",location_id,".csv"),row.names = FALSE)
log_info(paste0("Complete: Data saved for HU-",location_id))
log_info("SUCCESS")
print("SUCCESS")
close(log.file)

