##################################################
# Name: Culex Abundance Simulation 
# Description: function runs for loop over spatial-temporal solver 
#              for all timesteps of environmental data
# Public: LANL
# Username: Deborah Shutt dshutt@lanl.gov
# Version: 1.0
# Type:
# Documentation Link:
###################################################%

################ Inputs ##########################
# File 1: single_step_time_age.R 
#         runs cpmod which is one interation of the tracking of spatial-temporal rate of change
###################################################%

################ Arguments ##########################
# 1: times - timesteps vector which needs to match the environment inputs in length
# 2: parms - list of parameters for model
# 3: import1_Temp - vector of ave daily temperature
# 4: import2_DayHrs - vector of ave max daily daylight hrs
# 5: import3_Wet - vector of ave/normalized waterstation level or percipitation levels
###################################################%


################ Steps ##########################
# step 1: Source cpmod which is the one-step spatial temporal caluclation
# step 2: run CulexSimFun
# step 3: return Y1
###################################################%


############### Output ############################
# Final_Output:returns Active and Total mosquito populations
##################################################%

# In run file source cpmod for running one iteration of spatial-temporal change
# source("mosquito-pbm/code/model-source-functions/single_step_time_age.R")


CulexSimFunc = function(times, parms, import1_Temp, import2_DayHrs, import3_Wet, N = 100){
  
  init = parms['init'][[1]]
  
  # OutMat = matrix(rep(0.0, 2*length(times)), nrow = length(times), ncol = 2)
  #Add ability to output Eggs and LP stages 
  OutMat = matrix(rep(0.0, 2*length(times)), nrow = length(times), ncol =4)
  colnames(OutMat) = c('ActMosq', 'TotMosq','Eggs','LP')
  
  ## Initial conditions:
  yinout = rep(0.0, 6*N)
  yinout[(2*N + 1):(6*N)] = init
  
  for(i in 1:length(times)){
    out = cpmod(time = 1.0, yinout = yinout , parms = parms, 
                   import1_Temp = import1_Temp[i], import2_DayHrs = import2_DayHrs[i], 
                   import3_Wet = import3_Wet[i], N = N)
    yinout = out$yinout
    # Updating the results matrix
    OutMat[i,'ActMosq']  <- out$data[['ActMosq']][[1]]
    OutMat[i,'TotMosq']  <- out$data[['TotMosq']][[1]]
    OutMat[i,'Eggs']  <- out$data[['Eggs']][[1]]
    OutMat[i,'LP']  <- out$data[['LP']][[1]]
  }

  return(OutMat)
}
