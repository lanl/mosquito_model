### Summarise HU-forcing data from climate drivers
##### Summarise HU.csv files to daily
suppressPackageStartupMessages(library(tidyverse))
library(lubridate)
list.forcing <- list.files("/projects/cimmid/hydropops/Final_HP_Layers/na_10k/forcings/hourly/")
# ########## i. HU class summaries of forcings
# forcings <- data.frame()
for (i in 1:length(list.forcing)) {
  if(i%%250==0){
  print(paste("Completed:",i))
  }
  file_name <- list.forcing[i]
  forcings_daily <-read.csv(paste0("/projects/cimmid/hydropops/Final_HP_Layers/na_10k/forcings/hourly/",file_name)) %>% 
    mutate(date=as.Date(date)) %>%
    filter(year(date)>1995) %>%
    group_by(date) %>%
    summarise(sub_surface_runoff=sum(sub_surface_runoff),
              surface_runoff=sum(surface_runoff),
              total_precipitation=sum(total_precipitation),
              mean_temp=mean(temperature_2m)) %>%
    ungroup() 
  write.csv(forcings_daily,paste0("/projects/cimmid/users/kaitlynm/mosquito-pbm-local/input-data/hu-inputs/",file_name),row.names = FALSE)
}