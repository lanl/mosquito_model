### Daylight Hours
### Function to produce the daylight hrs variable for a location i


### Daylength definitions
# daylength_def <- 0.8333 ### US GOV definition
daylight.hrs <- function(latitude,longitude,start_date,end_date,daylength_def=0.8333){
  if (!is.element("tidyverse", installed.packages()[,1])){ # check if tidyverse is installed
    install.packages("tidyverse")
  }
  # library(tidyverse)
  date_seq <- seq(start_date,end_date,by="day")
  daylength_df <- data.frame(date=date_seq) %>% 
    mutate(day_of_year=as.numeric(format.Date(date_seq,format="%j"))) %>% 
    mutate(theta=0.2163108 +2*atan(0.9671396*tan(0.00860*(day_of_year-186))),
           phi=asin(0.39795*cos(theta)),
           DayLength=24-24/pi*acos((sin(daylength_def*pi/180)+
                                      sin(latitude*pi/180)*sin(phi))/
                                     (cos(latitude*pi/180)*cos(phi)))) %>% 
    select(date,DayLength)
  return(daylength_df)
}



# # Testing
# start_date <- as.Date("2009-01-01")
# end_date <- as.Date("2011-12-31")
# latitude <- 46.3166
# longitude <- -119.5000
# 
# output <- daylight.hrs(latitude,longitude,start_date,end_date)
