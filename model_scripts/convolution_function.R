#################################################
##################################################
# Name: Convolution For Age Progession in Adult Mosquito Life Stages
# Description: creates a function to convolve a randomly generated numerical pdf of age shift and current
#             count vector of individuals in respective life stage
# Public: LANL
# Username: Devin Goodsman/Deborah Shutt
# Version:
# Type:
# Documentation Link:
###################################################

#################################################
################ Inputs ##########################
# File 1:
#            created by
# File 2:
#            created by
# File 3:
#            created by
###################################################

#################################################
################ Parameters ##########################
# name 1:
# name 2:
# name 3:
###################################################

#################################################
################ Steps ##########################
# step 1:
# step 2:
# step 3:
###################################################

####################################################
############### Output ############################
# Output 1:
# Output 2:
# Final_Output: New age domain vector with mosquito counts at % age developement until
#               leaving current age stage
###############################################

# This function does a convolution of two variables of the same length
# but with padding on the right hand side
ConvolveFunc = function(x1, y1, padsize){
  # padding
  #x2 = c(rep(0,padsize), x1, rep(0,padsize))
  #y2 = c(rep(0,padsize), y1, rep(0,padsize))
  x2 = c(x1, rep(0.0,padsize))
  y2 = c(y1, rep(0.0,padsize))
  
  # fast Fourier transforming
  fx2 = fft(x2)
  fy2 = fft(y2)
  
  # Doing the convolution and inverse transforming
  Convolution1 = Re(fft(fx2*fy2, inverse = T)/length(x2))
  
  # Now clipping
  #Convolution2 = Convolution1[(padsize+1):(length(x1)+padsize)]
  Convolution2 = Convolution1[1:length(x1)]
  
  # Here I compute how many have moved into the padded region
  Emigrants = sum(Convolution1[(length(x1)+1):length(x2)])
  
  return(c(Convolution2, Emigrants))
}
