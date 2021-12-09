### Model Run
mosq.model <- function(parameters,hpu_MHI,forcing_data){
  #### From pbm-model-test-fxn.R ### 
  #### Step 1: Source Model Functions ####
  ### Paths have changed ##
  # call CulexSimFunc
  source(paste0(config_data$MODEL_RUN_SCRIPTS,"culex_simulation_function.R"))
  # call cpmod
  source(paste0(config_data$MODEL_RUN_SCRIPTS,"single_step_time_age.R"))
  # call ConvolveFunc
  source(paste0(config_data$MODEL_RUN_SCRIPTS,"convolution_function.R"))
  
  ### For Testing ##
  # parameters <- parameter_vec
  # hpu_MHI <- MHI_i
  # forcing_data <- forcing_data_i
  ###
  
  # Generate Wetness Index ####
  forcing_data$WetnessIndex <- forcing_data$precip_cm#*hpu_MHI
  
  # Assign to input vectors ####
  input1_Temp <- forcing_data$temp_C
  input2_DayHrs <- forcing_data$
  input3_Wet <- forcing_data$WetnessIndex 
  
  times<-seq(0,length(forcing_data$date)-1) ### changed 
  # daysteps <- external.signal$Daystep
  
  # Run Model ####
  model_out <- data.frame(CulexSimFunc(times, parms=parameters, input1_Temp, input2_DayHrs, input3_Wet))
  output <- model_out$TotMosq
  return(output)
}

