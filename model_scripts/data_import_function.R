data.import <- function(config_data, burnin){
  #Read in and clean mosquito population data
  ###adding a little filtering process if the start date of externals is later than observed, but this will probaly need to change later ###
  
  observed.data <- read.csv(config_data$MOSQ_DATA_PATH) %>% mutate(date=as.Date(date))
  ExternalInputs = read.csv(config_data$EXT_DATA_PATH, h = T) %>% mutate(date=as.Date(date))
  # earliest_common_daystep = max(c(min(observed.data$Daystep), min(ExternalInputs$Daystep)))
  earliest_common_date = max(c(min(observed.data$date), min(ExternalInputs$date)))

  # observed.data <- observed.data %>%
  #   filter(Daystep >= earliest_common_daystep)
  # ExternalInputs <- ExternalInputs %>%
  #   filter(Daystep >= earliest_common_daystep)
  # 
  observed.data <- observed.data %>%
    filter(date >= earliest_common_date)
  # ExternalInputs <- ExternalInputs %>%
  #   filter(date >= earliest_common_date)
  
  
  if(config_data$MODEL_RUN_TYPE =="train"){
    ### Training on 80% of the seasons. So if a training data set calculate the number of seasons
    observed.data <- observed.data %>%
      # mutate(Season = trunc(observed.data$Daystep/365)) %>%
      mutate(Season = year(date)) %>% 
      mutate(Set = ifelse(Season %in% unique(Season)[1:trunc(.80*length(unique(Season)))], 'train', 'test')) %>% # rounding down for more testing 
      filter(Set == 'train') %>%
      dplyr::select(-Set, -Season)
  }
  #ExternalInputs = read.csv(config_data$EXT_DATA_PATH, h = T) 
  #ultimately just standardize column names, but add below for Toronto data nameing conventions
  # if('Daystep' %in% colnames(ExternalInputs)){
  #   ExternalInputs <- ExternalInputs %>%
  #     rename(Datestep = Daystep)
  # }
  
 #  #Read in and clean external data
 #  daystep_start <- min(observed.data$Daystep) - burnin ## add extra days for both training and testing for the model to ramp up
 #  #commented out chunk below was an error in my previous code, with the ifelse is correct I believe, but I'm not sure
 #  daystep_end <- ifelse(config_data$MODEL_RUN_TYPE =="train",max(observed.data$Daystep),max(ExternalInputs$Datestep)) 
 # # daystep_end <- max(observed.data$Daystep)
  
  #Read in and clean external data
  date_start <- min(observed.data$date) - burnin ## add extra days for both training and testing for the model to ramp up
  date_end <- as.Date(ifelse(config_data$MODEL_RUN_TYPE =="train",max(observed.data$date),max(ExternalInputs$date)), origin = "1970-01-01" ) ## default date origin for R

  wet_cols <- config_data$WETNESS$column
  wet_weights <- config_data$WETNESS$val
  wet_list <- list()
  for (i in seq(1, length(wet_cols))){
    wet_list[i] <- ExternalInputs[wet_cols[i]] * wet_weights[i]
  }
  
  ExternalInputs$Wetness <- Reduce('+', wet_list)
    
  external.data <- ExternalInputs %>%
    # filter(Datestep >= daystep_start & Datestep <= daystep_end) %>%
    filter(date >= date_start & date <= date_end) %>%
    mutate(Daylighthrs = Daylighthrs - max(Daylighthrs)) %>%
    mutate(TimeSeq = seq(0, max(date) - min(date))) %>%
    #may need to redo how we do the naming of tempearture and other columns, wetness is fixed in the config file now
    # rename(Daystep = Datestep, Temperature = TempC) %>%
    rename(Temperature = TempC) #%>%
           #WaterLevel = LevelMean, Precip = PrecipMean) %>%
    # dplyr::select(-Daylighthrs) #%>%
    #weighted average of the two wetness options based on config inputs
    #mutate(Wetness = !!(as.symbol(names(config_data$WETNESS)[1])) * config_data$WETNESS[names(config_data$WETNESS)[1]][[1]] + !!(as.symbol(names(config_data$WETNESS)[2])) * config_data$WETNESS[names(config_data$WETNESS)[2]][[1]])
  
  data_list <- list('observed'=observed.data, 'external'=external.data)
  return(data_list) 
}

data.import.hu <- function(config_data, burnin,location_id){
  library(lubridate)
  #Read in and clean mosquito population data
  ###adding a little filtering process if the start date of externals is later than observed, but this will probaly need to change later ###
  ExternalInputs <-  read.csv(paste0(config_data$EXT_DATA_DIR,location_id,".csv"), h = T) 
  ## Rename Cols to match method column names
  colnames(ExternalInputs)[which(colnames(ExternalInputs)==config_data$DATE$column)] <- "date"
  colnames(ExternalInputs)[which(colnames(ExternalInputs)==config_data$TEMP$column)] <- "Temperature"
  ExternalInputs <- ExternalInputs %>% mutate(date=as.Date(date,format=config_data$DATE$format)) 
  #### Determine Start and End Dates 
  if(config_data$RUN_TYPE == 'train'){ 
    observed.data <- read.csv(config_data$MOSQ_DATA_PATH) %>% mutate(date=as.Date(date))
    observed.data <- observed.data %>%
        # mutate(Season = trunc(observed.data$Daystep/365)) %>%
        mutate(Season = year(date)) %>% 
        mutate(Set = ifelse(Season %in% unique(Season)[1:trunc(.80*length(unique(Season)))], 'train', 'test')) #%>% # rounding down for more testing 
        # filter(Set == 'train') %>%
        # dplyr::select(-Set, -Season)
    date_start <- min(observed.data$date) - burnin ## add extra days for both training and testing for the model to ramp up
    date_end <- max(observed.data$date)
    
  }else{
    observed.data <- NULL
    date_start <- as.Date(config_data$DATE$start_date,format =config_data$DATE$format)  - burnin ## add extra days for both training and testing for the model to ramp up
    date_end <- as.Date(config_data$DATE$end_date,format =config_data$DATE$format)
  }
  
  
  wet_cols <- config_data$WETNESS$column
  wet_weights <- config_data$WETNESS$val
  wet_list <- list()
  for (i in seq(1, length(wet_cols))){
    wet_list[i] <- ExternalInputs[wet_cols[i]] * wet_weights[i]
  }
  
  ExternalInputs$Wetness <- Reduce('+', wet_list)
  ### Filter to simulation range
  external.data <- ExternalInputs %>%
    filter(date >= date_start & date <= date_end) %>%
    mutate(TimeSeq = seq(0, max(date) - min(date))) 
  
  data_list <- list('observed'=observed.data, 'external'=external.data)
  
  return(data_list) 
}
