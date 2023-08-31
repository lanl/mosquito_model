### Summarise HU-forcing data from climate drivers
##### Summarise HU.csv files to daily
.libPaths("/usr/projects/cimmid/miniconda3/envs/mosq-R/lib/R/library/")
print(.libPaths())
suppressPackageStartupMessages(library(tidyverse))
library(lubridate)
list.forcing <- list.files(full.names=TRUE,pattern="^[0-9]",path="/lustre/scratch4/turquoise/.mdt5/jschwenk/na_10k_forcings")
# list.forcing <- list.files(pattern="^[0-9]",path="Desktop/DR/na_10k/forcings/hourly",full.names = TRUE)
list.forcing.nums <- gsub("/lustre/scratch4/turquoise/.mdt5/jschwenk/na_10k_forcings/","",list.forcing)
# list.forcing.nums <- gsub("Desktop/DR/na_10k/forcings/hourly/","",list.forcing)

already.complete <- list.files(pattern="[0-9]",path = "/lustre/scratch5/kaitlynm/mosquito_mod_data/input")
#already.complete <- list.files(pattern="[0-9]",path = "/usr/projects/cimmid/users/kaitlynm/mosquito_model/input")
# already.complete <- list.files(pattern="[0-9]",path = "Desktop/test-mosq/")

done.hu <- which(list.forcing.nums%in%already.complete)
if(length(done.hu)>0){
index <- (1:length(list.forcing))[-done.hu]
}else{
index<- 1:length(list.forcing)
}

#index <- (1:length(list.forcing))[-done.hu]
# ########## i. HU class summaries of forcings
# forcings <- data.frame()
print(length(list.forcing[index]))
for (i in index[1000:2000]){#length(list.forcing)) {
  if(i%%250==0){
    print(paste("Completed:",i))
  }
  file_name <- list.forcing[i]
  hu_num <- list.forcing.nums[i]
  forcings_daily <-read.csv(file_name) %>%
    mutate(date=as.Date(date)) %>%
    filter(year(date)>1995) %>%
    group_by(date) %>%
    summarise(sub_surface_runoff=sum(sub_surface_runoff),
              surface_runoff=sum(surface_runoff),
              total_precipitation=sum(total_precipitation),
              mean_temp=mean(temperature_2m)) %>%
    ungroup()
  # write.csv(forcings_daily,paste0("Desktop/test-mosq/",hu_num),row.names = FALSE)
 # write.csv(forcings_daily,paste0("/usr/projects/cimmid/users/kaitlynm/mosquito_model/input/",hu_num),row.names = FALSE)
   write.csv(forcings_daily,paste0("/lustre/scratch5/kaitlynm/mosquito_mod_data/input/",hu_num),row.names = FALSE)
}

