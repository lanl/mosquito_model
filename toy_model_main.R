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
log_info("Complete: Load R packages")

### Read in Config File ####
log_info("Start: Read In Config")
config_data <- yaml.load_file("mosq_config.yaml")
log_info("Complete: Read In Config")

### Source Model Run Scripts ####
log_info("Start: Source Model Functions")
source(paste0(config_data$MODEL_RUN_SCRIPTS,"/model_run.R"))
log_info("Complete: Source Model Functions")

### Read geo_json file ####
log_info("Start: Read In HPUs GeoJSON")
hpu_boundaries <- geojson_read(x = config_data$INPUTS$HYDROPOPS,what="sp")
hpu_ids <- hpu_boundaries@data$hpu_id
log_info("Complete: Read In HPUs GeoJSON")

### Make Dummy mosquito data for each hydropop ####
log_info("Start: Run Mosquito Model for each HydroPop Unit")
count <- 0
for(i in hpu_ids){
  hydropop_id <- i
  count <- count+1
  forcing_data_i <- read.csv(paste0(config_data$INPUTS$ENVIRONMENTAL_FORCING_DIR,
                                  "/hpu_",hydropop_id,"_forcing_data.csv"))
  start_date <- min(as.Date(forcing_data_i$date))
  end_date <- max(as.Date(forcing_data_i$date))
  MHI_i <- hpu_boundaries$mosq_hab_index[which(hpu_boundaries@data$hpu_id==hydropop_id)]
  log_info(paste0("Start: Hydropop ",i, " Model Run. ",count, "/", length(hpu_ids)))
  mosquito_vals <- mosq.model(parameters = 1,hpu_MHI = MHI_i,forcing_data = forcing_data_i)
  log_info(paste0("Complete: Hydropop ",i, " Model Run. ",count, "/", length(hpu_ids)))
  
  mosq_df <- data.frame(date=seq(start_date,end_date,by=1),
                        mosquito_count=mosquito_vals)
  write.csv(mosq_df,paste0(config_data$OUTPUT_DIR,"mosquito_df_hpu_",hydropop_id,".csv"))
  log_info(paste0("Complete: Model Data Saved Hydropop ",i))
  
}
log_info("Complete: Run Mosquito Model for each HydroPop Unit")
print("SUCCESS")