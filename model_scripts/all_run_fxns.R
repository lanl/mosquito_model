####Source Model Functions ####
library(subplex)
library(optimr)
# call CulexSimFunc
source("mosquito-pbm/code/model-source-functions/culex_simulation_function.R")
# call cpmod
#source("mosquito-pbm/code/model-source-functions/single_step_time_age.R")
#single step file now in the main file
# call ConvolveFunc
source("mosquito-pbm/code/model-source-functions/convolution_function.R")

run_model <- function(params, external.signal, N=100){
  input1_Temp<-external.signal$Temperature
  input2_DayHrs<-external.signal$Daylighthrs
  input3_Wet<-external.signal$Wetness
  
  times<-external.signal$TimeSeq
  # daysteps <- external.signal$Daystep
  dates <- external.signal$date
  
  
  model_out <- CulexSimFunc(times, params, input1_Temp, input2_DayHrs, input3_Wet, N)
  return(cbind(data.frame(model_out),times,input1_Temp,input2_DayHrs,input3_Wet,dates))
}

run_model_input <- function(input_fitted_params, params, external.signal, N){
  unlist_params <- unlist(params)
  unlist_params[names(input_fitted_params)] <- input_fitted_params
  new_params <- relist(unlist_params, params)

  return(run_model(new_params, external.signal, N))
}

fit_obj <- function(input_fit_params, params, external.signal, observed.data, N,thresholds=NULL){
  #input fit parameter initial guesses into the parameter list
  unlist_params <- unlist(params)
  unlist_params[names(input_fit_params)] <- input_fit_params
  new_params <- relist(unlist_params, params)
  ### Adding for temporary Fit reproduction
  # if(input_fit_params['Diapause.Int']<0){
  #   out <- run_model(new_params, external.signal, N)
  #   #having this be a data frame might increase comp time - check later
  #   out2 <- out$ActMosq
  # 
  #   #
  #   # daysteps<-observed.data$Daystep
  #   date<-observed.data$date
  #   ave_mosq_count<-observed.data$muCulex
  # 
  #   ### Shift output so that the 1st observed data point is compared to the output for that day from the model
  #   ### As long as the external data starts before or on the 1st observed data point this will function
  #   # shift <- which(external.signal$Daystep==min(daysteps))
  #   # Y = out2[c(daysteps - min(daysteps)+shift)]
  #   
  #   shift <- which(external.signal$date==min(date))
  #   Y = out2[c(date - min(date)+shift)]
  # 
  #   Y[is.na(Y) == TRUE] = 0.0
  #   Y[Y < 0.0] = 0.0
  # 
  #   # SSq = sum((Y - ave_mosq_count)^2) #This is the cost function we are minimizing but could be changed.
  #   SSq = sum((Y - ave_mosq_count)^2)/mean(ave_mosq_count)
  # }else{
  #   SSq=1000000000 ## Large number
  # }
  # return(SSq)
  
  ## Without bound on diapause int
  out <- run_model(new_params, external.signal, N)
  #having this be a data frame might increase comp time - check later
  out2 <- out$ActMosq

  #
  # daysteps<-observed.data$Daystep
  date<-observed.data$date
  ave_mosq_count<-observed.data$muCulex

  ### Shift output so that the 1st observed data point is compared to the output for that day from the model
  ### As long as the external data starts before or on the 1st observed data point this will function
  # shift <- which(external.signal$Daystep==min(daysteps))
  # Y = out2[c(daysteps - min(daysteps)+shift)]
  shift <- which(external.signal$date==min(date))
  Y = out2[c(date - min(date)+shift)]

  Y[is.na(Y) == TRUE] = 0.0
  Y[Y < 0.0] = 0.0

  # SSq = sum((Y - ave_mosq_count)^2) #This is the cost function we are minimizing but could be changed.
  SSq = sum((Y - ave_mosq_count)^2)/mean(ave_mosq_count)
  return(SSq)
}

fit_model <- function(input_fit_params, params, external.signal, observed.data, N){
  check <- fit_obj(unlist(input_fit_params), params, external.signal, observed.data, N)
  #change all these prints to logged statements for integration
  if(is.numeric(check)){
    print("Passed Check, starting full fit process.")
    # Now we start the minimization algorithm
    ptm = proc.time()
    # 4 Opimization ####
    set.seed(45) #we set the seed so that everytime we run the optimization algorithm
    #with the same values we will get the same result
    #Fit1 = optim(par = c(-1.0, 1.4, 6.0, -4.0, -30.0, 10.0), 
    #Fit1 = optim(par = c(DiapInt =-1.0, DiapCoef1 =1.4, OvipRate = 6.0, alpha1=-4.0, beta1=-30.0, init=10.0), 
    # Fit1 = subplex(par = unlist(input_fit_params),
    #              fn = fit_obj,
    #              params = params,
    #              external.signal = external.signal,
    #              observed.data = observed.data,
    #              N = N,
    #             # hessian = TRUE,
    #              control = list(reltol = 1e-8, maxit = 1000, parscale = c(1, 1, 1, 10, 10, 10)))
    # Fit1 = optimr(par = unlist(input_fit_params),
    #              fn = fit_obj,
    #              params = params,
    #              external.signal = external.signal,
    #              observed.data = observed.data,
    #              N = N,
    #              method = "Rcgmin",                         #Is there another option here for optimization? Levenworth-
    #              control = list(maxit = 10000), hessian = TRUE)
    Fit1 = optim(par = unlist(input_fit_params),
                 fn = fit_obj,
                 params = params,
                 external.signal = external.signal,
                 observed.data = observed.data,
                 N = N,
                 method = "Nelder-Mead",                         #Is there another option here for optimization? Levenworth-
                 control = list(maxit = 10000), hessian = TRUE)
    time_elapsed <- as.vector(proc.time() - ptm)
    cat("Fit Time: ",round(time_elapsed[3],4),"\n")
    if(Fit1$convergence==0){
      # Once the optimization algorithm has completed you can find the
      # the fitted parameter values by executing the following line:
      # Fit1$par
      # we use fitted.params to fill in the missing parameters before running
      # the model forward:
      fitted.params<-c(Fit1$par)
      return(fitted.params)
    }else{
      print("Parameter Fit Function DID NOT CONVERGE")
    }
  }else{
    print("SSqFunc did not produce a numerical result")
  }
}
