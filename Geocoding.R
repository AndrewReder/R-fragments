#Geocoding for missing Latitude and Longitude data
#Code is based on a csv file of municipal building permits (originally obtained from the City of Seattle)
#Original file has a large number of variables related to location and type of permit
#Every entry has a street address, but not every one has Latitude and Longitude data
#Start with package dependencies
install.packages("tidyverse")
library(tidyverse)
install.packages("ggmap")
library(ggmap)

#filter set to only work with entries with missing data
To_Geocode <- Building_Permits %>% filter(is.na(Latitude))

#Since municipal data assumes all addresses in the City, need to add City and State to work with geocoder
#This could be done by manipulating the To_Geocode dataset, but new sets are created here for debugging reasons
Addresses <- To_Geocode %>% mutate(Addresses = paste(To_Geocode$OriginalAddress1, c(", Seattle WA")))

#Geocoding using the Google Geocoding API (must register, free for this set <5000 elements, please check terms to avoid unexpected costs)
Addresses_ggmap <- geocode(location = Addresses$Addresses, output = "latlon", source = "google")

#Separating Latitude and Longitude to separate variables like in original dataset, stitching sets back together and renaming variables
To_Geocode <- To_Geocode %>% mutate(Latitude = Addresses_ggmap$lat, Longitude = Addresses_ggmap$lon)
Building_Permits <- Building_Permits %>% filter(!(is.na(Latitude))) %>% rbind(To_Geocode)
Building_Permits <- Building_Permits %>% mutate(City = "Seattle", State = "Washington", Address = OriginalAddress1, OriginalAddress1 = NULL)

