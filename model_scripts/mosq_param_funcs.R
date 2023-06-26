library(tidyverse)

erying <- function(temp, params){
  return(as.numeric(as.numeric(params['Psi'][[1]])*(273.15 + temp)*exp(-as.numeric(params['AE'][[1]])/(8.3144598*(273.15+temp)))))
}

briere <- function(temp, params){
  return(as.numeric(as.numeric(params['c'][[1]])*temp*(temp - as.numeric(params['T0'][[1]]))*sqrt(as.numeric(params['Tm'][[1]]) - temp)))
}

linear <- function(temp, params){
  return(as.numeric(as.numeric(params['Int'][[1]]) + as.numeric(params['Coef'][[1]])*temp))
}

sharpe_schoolfield <- function(temp, params){
    return((as.numeric(params['r'][[1]]) * ((temp + 273.15)/298) * exp((as.numeric(params['Ha'][[1]])/1.987) * (1/298 - 1/(temp + 273.15)))) / (1 + exp((as.numeric(params['Hh'][[1]])/1.987) * (1/as.numeric(params['T1_2'][[1]]) - 1/(temp + 273.15)))))
}

exponential <- function(wet, params){
  return(exp(as.numeric(params['alpha1'][[1]]) + as.numeric(params['beta1'][[1]])*wet))
}

diapause_exp <- function(dayhrs, params){
  return(1.0/(1.0 + exp(-(as.numeric(params['Int'][[1]]) - as.numeric(params['Coef'][[1]])*dayhrs))))
  # return(1.0/(1.0 + exp(-(as.numeric(-3) - as.numeric(1.5)*dayhrs))))
  # Following function taken from following source:
  # Critical Photoperiod and Its Potential to Predict
  # Mosquito Distributions and Control Medically Important Pests
  # Authors: Peffers, Caitlin S., Pomeroy, Laura W., and Meuti, Megan E
  # logit_func = function(x){
  #   return(log(x/(1-x)))
  # }
  # 
  # logit_inverse_func = function(x){
  #   return(1/(1+exp(-x)))
  # }
  # test_vec_diapause = c(.999999, .99999, .9999, .999, 0.1, 0.00001 , 0.000001)
  # test_vec_light_per_day = c(8,12,12.5,13,13.5,14,16)
  # df_diapause_light_data = data.frame(matrix(ncol = 2, nrow = length(test_vec_diapause)))
  # names(df_diapause_light_data) = c('diapause_data', 'light_data')
  # df_diapause_light_data$diapause_data = test_vec_diapause
  # logit_transformed_diapause_data = log(df_diapause_light_data$diapause_data / (1 - df_diapause_light_data$diapause_data))
  # df_diapause_light_data$light_data = test_vec_light_per_day
  # logit_model_diapause_versus_light = (glm(logit_transformed_diapause_data ~ df_diapause_light_data$light_data))
  # linear_intercept = as.numeric(logit_model_diapause_versus_light$coefficients[1])
  # linear_slope = as.numeric(logit_model_diapause_versus_light$coefficients[2])
  # return(logit_inverse_func(linear_intercept + linear_slope*dayhrs))
}

calc_mosq_atr <- function(env_var, params){
  if (params['func'][[1]] == 'erying'){
    val <- erying(env_var, params)
  }
  if (params['func'][[1]] == 'briere'){
    val <- briere(env_var, params)
  }
  if (params['func'][[1]] == 'linear'){
    val <- linear(env_var, params)
  }
  if (params['func'][[1]] == 'sharpe-schoolfield'){
    val <- sharpe_schoolfield(env_var, params)
  }
  if (params['func'][[1]] == 'exponential'){
    val <- exponential(env_var, params)
  }
  if (params['func'][[1]] == 'diapause_exp'){
    val <- diapause_exp(env_var, params)
  }
  return(val)
}