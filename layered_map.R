library(png) 
library(ggmap)
library(leaflet)
library(plyr)
library(rgdal)
library(maps)

clean.data.dir <-  '/Users/elizabethsweeney/Dropbox/Elizabeth_Sweeney_Documents/Current_Projects/jhudashbike/clean_data/'

load(paste0(clean.data.dir, 'bikepaths.rda'))
acc.arrest.haz.data <- read.csv(paste0(clean.data.dir , 'Hazards_Accidents_Crimes.csv'))
hazard <- acc.arrest.haz.data[acc.arrest.haz.data$type == 'Hazard',]
arrest <- acc.arrest.haz.data[acc.arrest.haz.data$type == 'Arrest',]
accident <- acc.arrest.haz.data[acc.arrest.haz.data$type == 'Accident',]


icon.dir <- '/Users/elizabethsweeney/Dropbox/Elizabeth_Sweeney_Documents/Current_Projects/jhudashbike/icons/'


height = 15
crashIcon <- makeIcon(
  iconUrl = "icon_fire.png",
  iconWidth = height, iconHeight = height)

height = 15
bikeIcon <- makeIcon(
  iconUrl = "biker_pothole.jpg",
  iconWidth = height, iconHeight = height)



# baltimore city boundary

bdy <- matrix(c(-76.7113,39.372, -76.5297,39.372, -76.5299,39.2096, -76.5497,39.1972,
                -76.5837,39.2081, -76.6116,39.2344, -76.7112,39.2778, -76.7113,39.372), ncol=2, byrow=TRUE)
bdy <- as.data.frame(bdy)
colnames(bdy) <- c("lon", "lat")


# baltimore city map

m <- leaflet() %>% fitBounds(min(bdy$lon), min(bdy$lat), max(bdy$lon), max(bdy$lat)) %>% addProviderTiles("CartoDB.Positron") %>% addPolygons(lng=bdy$lon, lat=bdy$lat)

# bike paths 

for(i in 1:length(bike.paths)){
	m <- m %>% addPolylines(lng=as.matrix(bike.paths[[i]])[,1], lat=as.matrix(bike.paths[[i]])[,2])
    print(i) 	
}


# baltimore city map


m <- m %>% addCircleMarkers(lng=acc.arrest.haz.data$lon[acc.arrest.haz.data$type == 'Hazard'], lat=acc.arrest.haz.data$lat[acc.arrest.haz.data$type == 'Hazard'],
                     fillOpacity=0.5, color="Orchid",
                    , group="Hazard", radius = 1) %>%
    addCircleMarkers(lng=acc.arrest.haz.data$lon[acc.arrest.haz.data$type == 'Arrest'], lat=acc.arrest.haz.data$lat[acc.arrest.haz.data$type == 'Arrest'],
                     fillOpacity=0.5, color="slateblue", group="Arrest", radius = 1) %>%
    addCircleMarkers(lng=acc.arrest.haz.data$lon[acc.arrest.haz.data$type == 'Accident'], lat=acc.arrest.haz.data$lat[acc.arrest.haz.data$type == 'Accident'],
                     fillOpacity=0.5, color="orange", group="Accident", radius = 1) %>%
    addLayersControl(baseGroups=c("CartoDB"),
                     overlayGroups=c("Hazard", "Arrest", "Accident"),
                     options=layersControlOptions(collapsed=FALSE))



m <- m %>%  addCircleMarkers(lng=accident.cords$lon, lat=tows$lat[stolen],
                     popup=paste0("$", tows$charge[stolen], "\n", tows$address[stolen]),
                     fillOpacity=0.5, color="Orchid",
                     radius=tows$charge[stolen]/130+1, group="Stolen")


addMarkers(lng = accident.cords$lon, lat = accident.cords$lat, icon = crashIcon)

#hazards

m <- m %>%  addMarkers(lng = hazard$lon, lat = hazard$lat, icon = bikeIcon) 
