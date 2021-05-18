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
library(geojsonio)

### Read in Config File ####
config_data <- yaml.load_file("mosq_config.yaml")

### Read geo_json file ####
hpu_boundaries <- geojson_read(x = config_data$INPUTS$HYDROPOPS,what="sp")
hpu_ids <- hpu_boundaries@data$hpu_id

### Make Dummy mosquito data for each hydropop ####
for(i in hpu_ids){
  hydropop_id <- i
  forcing_data_i <- read.csv(paste0(config_data$INPUTS$ENVIRONMENTAL_FORCING_DIR,
                                  "/hpu_",hydropop_id,"_forcing_data.csv"))
  start_date <- min(as.Date(forcing_data_i$date))
  end_date <- max(as.Date(forcing_data_i$date))
  
  mosquito_vals <- scale(forcing_data_i$temp_C*forcing_data_i$precip_cm,
                         center=FALSE)*100*hpu_boundaries$mosq_hab_index[which(hpu_boundaries@data$hpu_id==hydropop_id)]
  
  mosq_df <- data.frame(date=seq(start_date,end_date,by=1),
                        mosquito_count=mosquito_vals)
  write.csv(mosq_df,paste0(config_data$OUTPUT_DIR,"mosquito_df_hpu_",hydropop_id,".csv"))
}
