rm( list = ls() )
library(rgdal)
library(rgeos)
library(leaflet)
setwd("~/Dropbox/jhudash/jhudashbike/Traffic")
setwd("Statewide_TMS_Locations")
gor = readOGR(".", "Statewide_TMS_Locations")

gor = gor[ gor$COUNTY_DES == "Baltimore City",]

df <- sp::SpatialPointsDataFrame(
  cbind(
    (runif(20) - .5) * 10 - 90.620130,  # lng
    (runif(20) - .5) * 3.8 + 25.638077  # lat
  ),
  data.frame(type = factor(
    ifelse(runif(20) > 0.75, "pirate", "ship"),
    c("ship", "pirate")
  ))
)


leaflet(gor) %>% addTiles() %>% 
  # Select from oceanIcons based on df$type
  addMarkers(icon = ~oceanIcons[type])

leaflet() %>% addTiles() %>% addPolygons(data=gor, weight=2)

subdat<-spTransform(gor, CRS("+init=epsg:4326"))

subdat_data<-subdat@data[,c("ROUTEID", "SMALL_TRUC")]

subdat<-gSimplify(subdat,tol=0.01, topologyPreserve=TRUE)

subdat<-SpatialPolygonsDataFrame(subdat, 
    data=subdat_data)