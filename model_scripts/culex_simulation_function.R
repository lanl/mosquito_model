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
# 3: import1 - vector of ave daily temperature
# 4: import2 - vector of ave max daily daylight hrs
# 5: import3 - vector of ave/normalized waterstation level or percipitation levels
###################################################%


################ Steps ##########################
# step 1: Source cpmod which is the one-step spatial temporal caluclation
# step 2: run CulexSimFun
# step 3: return Y1
###################################################%


############### Output ############################
# Final_Output:returns Y1 = OutMat[,601] we only save the information from the last column
#          of the solution matrix = single time step of total 
#         number of ActMosq 
##################################################%

# In run file source cpmod for running one iteration of spatial-temporal change
# source("mosquito-pbm/code/model-source-functions/single_step_time_age.R")


CulexSimFunc = function(times, parms, import1, import2, import3, N = 100){
  
  #init = parms[15]
  init = parms['init'][[1]]
  
  # A matrix to hold simulation results
  #OutMat = matrix(rep(0.0, 602*length(times)), nrow = length(times), ncol = 602)
  
  OutMat = matrix(rep(0.0, 2*length(times)), nrow = length(times), ncol = 2)
  colnames(OutMat) = c('ActMosq', 'TotMosq')
  
  ## Initial conditions:
  #yinout = rep(0.0, 600)
  #yinout[201:600] = init
  yinout = rep(0.0, 6*N)
  yinout[(2*N + 1):(6*N)] = init
  
  #out_data = list()
  for(i in 1:length(times)){
    # yinout = cpmod(time = 1.0, yinout = yinout , parms = parms, 
    #                input1 = import1[i], input2 = import2[i], 
    #                input3 = import3[i])
    
    # Updating the results matrix
    #OutMat[i,] = yinout
    out = cpmod(time = 1.0, yinout = yinout , parms = parms, 
                   input1 = import1[i], input2 = import2[i], 
                   input3 = import3[i])
    yinout = out$yinout
    #out_data[[i]] <- as.data.frame(out$data)
    OutMat[i,'ActMosq']  <- out$data[['ActMosq']][[1]]
    OutMat[i,'TotMosq']  <- out$data[['TotMosq']][[1]]
  }
  
  #final_out = do.call(rbind, out_data)
  #activeMosq = OutMat[,601]
  #totalAD = OutMat[,602]
  #return(list(activeMosq,totalAD))
  #return(final_out)
  return(OutMat)
}
