#### Toy model

### Inputs 
# Wetness
# Temperature
# Lat/Long
# start/stop date
# HTHI

### Outputs
# Mosquito Population csv for each hydro pop

### Libraries 
library(yaml) # to read in yaml file
options("rgdal_show_exportToProj4_warnings"="none")
library(sp)
library(rgdal) # read geojsons
library(logger) # logger package
library(tidyverse) # Data manipulation

### Read in Config File ####
args <- commandArgs(trailingOnly = TRUE)
config_file=args[1]
config_data <- yaml.load_file(config_file)
## For testing ##
# config_data <- yaml.load_file("mosq_config.yaml")
##

### Set Up Log File ####
log.file <- file(config_data$LOGFILE_PATH)
log_appender(appender_file(config_data$LOGFILE_PATH,append = T))

### Source Model Run Scripts ####
# log_info("Start: Source Model Functions")
source(paste0(config_data$MODEL_RUN_SCRIPTS,"model_run.R"))
source(paste0(config_data$MODEL_RUN_SCRIPTS,"daylight-hrs-fxn.R"))
log_info("Complete: Source Model Functions")

### Read geo_json file ####
# log_info("Start: Read In HPUs GeoJSON")
hpu_boundaries <- readOGR(config_data$INPUTS$HYDROPOPS)
## For Testing ##
# hpu_boundaries <- readOGR("input/HPU_shapefiles/")
##
hpu_ids <- hpu_boundaries@data$hpu_id
log_info("Complete: Read In HPUs Shapefiles")


### Set up Parameters from Config File ## 
parameter_vec <- c(unlist(config_data$PARAMETERS$MOSQ_PARAMS_STD),
                   unlist(config_data$PARAMETERS$MOSQ_PARAMS_FITTED))
wetness_index_wts <- unlist(config_data$PARAMETERS$WETNESS_INDEX) 

### Run Mosquito Model for each hydropop ####
log_info("Start: Run Mosquito Model for each HydroPop Unit")
count <- 0
for(i in hpu_ids[1:10]){ # making it 1:10 for now for testing purposes until parallel ideas implemented. 
  hydropop_id <- i
  count <- count+1
  forcing_data_i <- read.csv(paste0(config_data$INPUTS$ENVIRONMENTAL_FORCING_DIR,
                                  "/Toronto_fauxELM_output_testrun.csv"))
  ## For Testing ##
  # forcing_data_i <- read.csv(paste0("input/elm_output/","Toronto_fauxELM_output_testrun.csv"))
  #
  start_date <- min(as.Date(forcing_data_i$date))
  end_date <- max(as.Date(forcing_data_i$date))
  HTHI_i <- hpu_boundaries$hthi_mean[which(hpu_boundaries@data$hpu_id==hydropop_id)]
  # calculate daylight hours from lat/long and date range
  forcing_data_i$daylight_hrs <- daylight.hrs(latitude = hpu_boundaries$centroid_y[which(hpu_boundaries@data$hpu_id==hydropop_id)],
                                              longitude = hpu_boundaries$centroid_x[which(hpu_boundaries@data$hpu_id==hydropop_id)],
                                              start_date = start_date,end_date = end_date)$DayLength
  log_info(paste0("Start: Hydropop ",i, " Model Run. ",count, "/", length(hpu_ids)))
  forcing_data_i$WetnessIndex <- apply( forcing_data_i[names(wetness_index_wts)],1,weighted.mean,as.numeric(wetness_index_wts))
  mosquito_vals <- HTHI_i*mosq.model(parameters = parameter_vec,hpu_HTHI = HTHI_i,forcing_data = forcing_data_i)
  
  mosq_df <- data.frame(date=seq(start_date,end_date,by=1),
                        mosquito_count=mosquito_vals)
  write.csv(mosq_df,paste0(config_data$OUTPUT_DIR,"mosquito_df_hpu_",hydropop_id,".csv"))
  log_info(paste0("Complete: Hydropop ",i, " Model Run. ",count, "/", length(hpu_ids),". Data Saved."))
  
}
log_info("Complete: Run Mosquito Model for each HydroPop Unit")
log_info("SUCCESS")
print("SUCCESS")
close(log.file)

