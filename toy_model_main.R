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
options("rgdal_show_exportToProj4_warnings"="none")
library(sp)
library(rgdal) # read geojsons
library(logger) # logger package

### Read in Config File ####
config_data <- yaml.load_file("mosq_config.yaml")

### Set Up Log File ####
log.file <- file(config_data$LOGFILE_PATH)
log_appender(appender_file(config_data$LOGFILE_PATH,append = T))

### Source Model Run Scripts ####
# log_info("Start: Source Model Functions")
source(config_data$MODEL_RUN_SCRIPTS)
log_info("Complete: Source Model Functions")

### Read geo_json file ####
# log_info("Start: Read In HPUs GeoJSON")
hpu_boundaries <- readOGR(config_data$INPUTS$HYDROPOPS)
FROM_GeoJson(url_file_string = config_data$INPUTS$HYDROPOPS)
  geojson_read(x = config_data$INPUTS$HYDROPOPS,what="sp")
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
  
  mosq_df <- data.frame(date=seq(start_date,end_date,by=1),
                        mosquito_count=mosquito_vals)
  write.csv(mosq_df,paste0(config_data$OUTPUT_DIR,"mosquito_df_hpu_",hydropop_id,".csv"))
  log_info(paste0("Complete: Hydropop ",i, " Model Run. ",count, "/", length(hpu_ids),". Data Saved."))
  
}
log_info("Complete: Run Mosquito Model for each HydroPop Unit")
log_info("SUCCESS")
print("SUCCESS")
close(log.file)

