#### Toy model

### Inputs 
# Wetness
# Temperature
# Lat/Long
# start/stop date
# MHI

### Outputs
# Mosquito Population csv for each hydro pop

### Libraries 
library(yaml) # to read in yaml file
library(geojsonio) # read geojsons
library(logger) # logger package

### Read in Config File ####
log_info("Read In Config")
config_data <- yaml.load_file("mosq_config.yaml")

### Source Model Run Scripts ####
log_info("Source Model Functions")
source(paste0(config_data$MODEL_RUN_SCRIPTS,"/model_run.R"))

### Read geo_json file ####
log_info("Read In HPUs GeoJSON")
hpu_boundaries <- geojson_read(x = config_data$INPUTS$HYDROPOPS,what="sp")
hpu_ids <- hpu_boundaries@data$hpu_id

### Make Dummy mosquito data for each hydropop ####
log_info("Run Mosquito Model for each HydroPop Unit")
for(i in hpu_ids){
  hydropop_id <- i
  forcing_data_i <- read.csv(paste0(config_data$INPUTS$ENVIRONMENTAL_FORCING_DIR,
                                  "/hpu_",hydropop_id,"_forcing_data.csv"))
  start_date <- min(as.Date(forcing_data_i$date))
  end_date <- max(as.Date(forcing_data_i$date))
  MHI_i <- hpu_boundaries$mosq_hab_index[which(hpu_boundaries@data$hpu_id==hydropop_id)]
  mosquito_vals <- mosq.model(parameters = 1,hpu_MHI = MHI_i,forcing_data = forcing_data_i)
  
  mosq_df <- data.frame(date=seq(start_date,end_date,by=1),
                        mosquito_count=mosquito_vals)
  write.csv(mosq_df,paste0(config_data$OUTPUT_DIR,"mosquito_df_hpu_",hydropop_id,".csv"))
}
