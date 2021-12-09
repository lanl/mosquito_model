############### General Information ###################################
# Name: Single change in Spatio-Temporal step
# Description: This function with solve the pde for mosquito abundance in the Greater Toronto Area
#             at a single timestep called 'time' using the method of characteristics
# Public: LANL
# Username: Devin Goodsman/Deborah Shutt dshutt@lanl.gov
# Version: 2.0
# Type:
# Documentation Link:
##################################################################%

################ Inputs ##########################
# File 1: convolution_function.R
#         function will generate the radom shift in the adult mosquito populations
#         for all stages AD1 - AD4
###################################################%


################ Arguments ##########################
# 1 : time equal to 1 as this is the timestep of the collected environment data
# 2 : yinout = vector of counts of individuals across age domains
#         i.e. yinout = c(Eggs,LP, AD1, AD2, AD3, AD4, ActMosq)
# 3 : parms = those parameters which were both fitted and found in lit
# 4 : input1 = entry at single timestep of ave daily temperature 
# 5 : input2 = entry at single timestep of ave max num of daylight hrs 
# 6 : input3 = entry at single timestep of ave/normalized waterstation level of SB02HB 
###################################################%

################ Steps ##########################
# step 1: Source the convolution function used with in the cpmod function
# step 2: Set parameters and intitialize the population vector yinout
# step 3: Assuming the input1 is above min temp, kill off Larvae-pupae based on temp and 
#         population density and kill off adult mosquitos based on Erying equation death rate
###################################################%


############### Output ############################
# Output 1:
# Output 2:
# Final_Output:
###############################################%

# Here is the PDE model solved by method of characteristics.
# The first input is the mean temperature in degrees C at the specified time.
# The second input is the daylength at the specified time, which impacts the
# proportion of adult mosquitos in diapause.
# The third input is the lake level in m.
# This function does the calculations for a single time step.

# This function calls the convolution function, "find" ConvolveFunc to locate:
# source("mosquito-pbm/code/model-source-functions/convolution_function.R")

cpmod = function(time, yinout, parms, input1, input2, input3, N = 100){
  
  # Setting up the domain
  #N  = 100                      # Number of boxes in the discretized domain for each life stage
  da = 1.0/N               # thickness of each box
  
  # Defining all of the parameters
  # DiapInt = parms[1]    # diapause intercept for logistic regression model
  # DiapCoef1 = parms[2]  # (negative) slope proportion in diapause changes with respect to day length
  # PsiEggs = parms[3]    # first parameter of Eyring equation for egg development rate
  # AEE = parms[4]        # activation energy parameter of Eyring equation for egg development (negative)
  # ThetaLP = parms[5]    # first parameter of Briere equation for larval-pupal development rate
  # TMLP = parms[6]       # maximum temperature for Larval-pupal development rate in Briere equation
  # IntAd = parms[7]      # intercept controling rate at which adults progress through embryonation
  # Coef1Ad = parms[8]    # slope controling rate at which adults progress through embryonation
  # PsiAd = parms[9]     # first parameter of Eyring equation for adult mortality rate
  # AEAd = parms[10]      # activation energy parameter of Eyring equation for adult mortality (negative)
  # Cutoff = parms[11]    # temperature cutoff below which no development happens fitted to larvae-pupae.
  # OvipRate = parms[12]  # oviposition rate.
  # alpha1 = parms[13]    # controls Culex density dependent mortality
  # beta1 = parms[14]     # adjusts Culex density dependence as a function of water levels
  DiapInt = parms['DiapInt'][[1]]   # diapause intercept for logistic regression model
  DiapCoef1 = parms['DiapCoef1'][[1]]  # (negative) slope proportion in diapause changes with respect to day length
  PsiEggs = parms['PsiEggs'][[1]]   # first parameter of Eyring equation for egg development rate
  AEE = parms['AEE'][[1]]       # activation energy parameter of Eyring equation for egg development (negative)
  ThetaLP = parms['ThetaLP'][[1]]    # first parameter of Briere equation for larval-pupal development rate
  TMLP = parms['TMLP'][[1]]       # maximum temperature for Larval-pupal development rate in Briere equation
  IntAd = parms['IntAd'][[1]]      # intercept controling rate at which adults progress through embryonation
  Coef1Ad = parms['Coef1Ad'][[1]]    # slope controling rate at which adults progress through embryonation
  PsiAd = parms['PsiAd'][[1]]     # first parameter of Eyring equation for adult mortality rate
  AEAd = parms['AEAd'][[1]]      # activation energy parameter of Eyring equation for adult mortality (negative)
  Cutoff = parms['Cutoff'][[1]]    # temperature cutoff below which no development happens fitted to larvae-pupae.
  OvipRate = parms['OvipRate'][[1]] # oviposition rate.
  alpha1 = parms['alpha1'][[1]]    # controls Culex density dependent mortality
  beta1 = parms['beta1'][[1]]     # adjusts Culex density dependence as a function of water levels
  
  # If temperature is below zero degrees C, we kill off all of the aquatic
  # life stages
  #Fix the numerical indexing below later - Martha
  # if(input1 < 0.0){
  #   yinout[1:200] = 0.0
  # }
  
  if(input1 < 0.0){
    yinout[1:(2*N)] = 0.0
  }
  
  # subsetting the different life stages
  # Eggs = yinout[1:100] # Egg stage
  # LP = yinout[101:200] # L1 to pupa stages
  # AD1 = yinout[201:300] # first gonotrophic cycle of adult stage
  # AD2 = yinout[301:400] # second gonotrophic cycle of adult stage
  # AD3 = yinout[401:500] # third gonotrophic cycle of adult stage
  # AD4 = yinout[501:600] # fourth gonotrophic cycle of adult stage
  
  Eggs = yinout[1:(N)] # Egg stage
  LP = yinout[(N + 1):(2*N)] # L1 to pupa stages
  AD1 = yinout[(2*N + 1):(3*N)] # first gonotrophic cycle of adult stage
  AD2 = yinout[(3*N + 1):(4*N)] # second gonotrophic cycle of adult stage
  AD3 = yinout[(4*N + 1):(5*N)] # third gonotrophic cycle of adult stage
  AD4 = yinout[(5*N + 1):(6*N)] # fourth gonotrophic cycle of adult stage
  
  # here are the age domains for each life stage
  ageEggs = seq(da, 1.0, by = da)
  ageLP = seq(da, 1.0, by = da)
  ageAD1 = seq(da, 1.0, by = da)
  
  #----------------------------------------------------------------------------------------------
  # first I solve the reaction part of the models for each life stage:
  
  if(input1 > Cutoff){
    # I can compute the analytic solution for the integro-differential equation for
    # competition in the combined larval and pupal stages. 
    # The density dependent mortality coefficient for lake level:
    ddmortLP = as.numeric(exp(alpha1 + beta1*input3)) # density-dependent mortality coefficient
    LP = LP/(1.0 + ddmortLP*sum(LP)*da*time)
    # LP = LP*exp(-ddmortLP*time)
    # Adults die by dropping off the edge of their age domain or by a density independent
    # temperature mortality rate.
    dimortAD = as.numeric(PsiAd*(273.15 + input1)*exp(-AEAd/(8.3144598*(273.15 + input1))))
    AD1 = AD1*exp(-dimortAD*time)
    AD2 = AD2*exp(-dimortAD*time)
    AD3 = AD3*exp(-dimortAD*time)
    AD4 = AD4*exp(-dimortAD*time)
  }
  
  #----------------------------------------------------------------------------------------------
  # Now I do the shifting.
  
  # First I will compute the proportion of adults in diapause. This will be used for addition
  # of eggs to the first age of the egg age domain as adults only oviposit if not in diapause.
  # Here I compute the proportion of Culex that are diapausing.
  DiapProp = 1.0/(1.0 + exp(-(DiapInt - DiapCoef1*input2)))
  
  # setting up maturation velocities
  if(input1 > Cutoff){
    vtE = as.numeric(PsiEggs*(273.15 + input1)*exp(-AEE/(8.3144598*(273.15+input1)))) # for eggs
  }else{
    vtE = 0.0
  }
  
  if(input1 > Cutoff & input1 <= TMLP){
    vtLP = as.numeric(ThetaLP*input1*(input1 - Cutoff)*sqrt(TMLP - input1)) # for L1 to pupae
  }else{
    vtLP = 0.0
  }
  
  if(input1 > Cutoff){
    vtA = as.numeric(IntAd + Coef1Ad*input1) # for adults
  }else{
    vtA = 0.0
  }
  
  # reseting the individuals that have reached each gonotrophic cycle to zero
  g1 = 0.0; g2 = 0.0; g3 = 0.0; g4 = 0.0
  
  if(input1 > Cutoff){
    EggsShifted = ageEggs + rep(vtE*time, length(ageEggs))
    LPShifted = ageLP + rep(vtLP*time, length(ageLP))
    
    # Pupae that exceed the pupal break point enter the adult stage as below. All others
    # are shifted to the right with boxes replaced on the left side of the age domain.
    LP = c(rep(0.0, length(LPShifted[LPShifted > 1.0])), LP[LPShifted <= 1.0])
    
    # Eggs that exceed the egg breakpoint are added to the first age of LP age domain.
    # To prevent spikes, we divide the new LP individuals evenly among the new boxes.
    LP[1:length(LPShifted[LPShifted > 1.0])] = LP[1:length(LPShifted[LPShifted > 1.0])] +
      sum(Eggs[EggsShifted > 1.0])/length(LPShifted[LPShifted > 1.0])
    
    # First gonotrophic cycle
    # Computing the gamma distributed development rate.  
    # On option is we will hold the shape
    # parameter in the gamma distribution fixed at the slope of the rate of development
    # vtA which had been evaluated based on TempC input1 but after some analysis we see 
    # that the distributions do not change significantly due to TempC: see investigating.R
    # MAD = dgamma(x = ageAD1, shape = Coef1Ad, rate = 1)
    
    #The other option is to vary the shape of the aging distribution by the
    #temp input
    # MAD = dgamma(x = ageAD1, shape = vtA*time, rate = 1)
    MAD = dexp(x=ageAD1, rate = 1/vtA*time)
    MAD = MAD/sum(MAD) # Normalizing
    NewAD1 = ConvolveFunc(x1 = AD1, y1 = MAD, padsize = length(AD1))
    #AD1 = NewAD1[1:100]
    AD1 = NewAD1$conv
    AD1[1] =  AD1[1] + sum(LP[LPShifted > 1.0]) # We dont divide by da here because we also multiply by da
    #g1 = NewAD1[101]*da # We multiply by da because this is the Reiman sum approximation
    g1 = NewAD1$emigrants*da # We multiply by da because this is the Reiman sum approximation
    
    # second gonotrophic cycle
    NewAD2 = ConvolveFunc(x1 = AD2, y1 = MAD, padsize = length(AD2))
    #AD2 = NewAD2[1:100]
    AD2 = NewAD2$conv
    AD2[1] =  AD2[1] + g1/da # We divide by da because this is a Dirac delta function approximation
    #g2 = NewAD2[101]*da # We multiply by da because this is the Reiman sum approximation
    g2 = NewAD2$emigrants*da # We multiply by da because this is the Reiman sum approximation
    
    # Third gonotrophic cycle.
    NewAD3 = ConvolveFunc(x1 = AD3, y1 = MAD, padsize = length(AD3))
    #AD3 = NewAD3[1:100]
    AD3 = NewAD3$conv
    AD3[1] =  AD3[1] + g2/da # We divide by da because this is a Dirac delta function approximation
    #g3 = NewAD3[101]*da # We multiply by da because this is the Reiman sum approximation
    g3 = NewAD3$emigrants*da # We multiply by da because this is the Reiman sum approximation
    
    # fourth gonotrophic cycle.
    NewAD4 = ConvolveFunc(x1 = AD4, y1 = MAD, padsize = length(AD4))
    #AD4 = NewAD4[1:100]
    AD4 = NewAD4$conv
    AD4[1] =  AD4[1] + g3/da # We divide by da because this is a Dirac delta function approximation
    #g4 = NewAD4[101]*da # We multiply by da because this is the Reiman sum approximation
    g4 = NewAD4$emigrants*da # We multiply by da because this is the Reiman sum approximation
    
    # Eggs that exceed the egg greak point enter the larval stage as above. All others are
    # shifted to the right with boxes replaced on the left side of the age domain.
    Eggs = c(rep(0.0, length(EggsShifted[EggsShifted > 1.0])), Eggs[EggsShifted <= 1.0])
    
    # Eggs are added to the first age of the egg domain by adult oviposition.
    # Oviposition for Culex pipiens
    Ovipos = OvipRate*(1.0 - DiapProp)*(g1 + g2 + g3 + g4)*time
    #Eggs[1] = Eggs[1] + Ovipos/da
    Eggs[1:length(EggsShifted[EggsShifted > 1.0])] = Eggs[1:length(EggsShifted[EggsShifted > 1.0])] + 
      Ovipos/(length(EggsShifted[EggsShifted > 1.0])*da)
  }
  
  #----------------------------------------------------------------------------------------------
  # I compute an estimate of the number of active mosquitos
  #ActivMos = (1.0 - DiapProp)*(sum(AD1) + sum(AD2) + sum(AD3) + sum(AD4))
  ActivMosq = (1.0 - DiapProp)*(g1 + g2 + g3 + g4)
  TotalMosq = sum(AD1) + sum(AD2) + sum(AD3) + sum(AD4)
  # updating the state variables
  #yinout = c(Eggs, LP, AD1, AD2, AD3, AD4, ActivMos,TotalMosq)
  out = list(yinout = c(Eggs, LP, AD1, AD2, AD3, AD4), data = c('ActMosq' = ActivMosq, 'TotMosq' = TotalMosq))
  #return(yinout)
  return(out)
}
