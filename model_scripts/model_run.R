### Model Run
mosq.model <- function(parameters,hpu_MHI,forcing_data){
  output <- scale(forcing_data$temp_C*forcing_data$precip_cm,center=FALSE)* 100*hpu_MHI*parameters
  return(output)
}

