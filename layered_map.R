library(png) 
library(ggmap)
library(leaflet)
library(plyr)
library(rgdal)
library(maps)

clean.data.dir <-  '/Users/elizabethsweeney/Dropbox/Elizabeth_Sweeney_Documents/Current_Projects/jhudashbike/clean_data/'

load(paste0(clean.data.dir, 'accidents.rda'))
load(paste0(clean.data.dir, 'bikepaths.rda'))
hazards <- read.csv(paste0(clean.data.dir , 'Hazards.csv'))
potholes <- hazards[hazards$code == 'POTHOLES',]

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

m <- m %>%  addMarkers(lng = as.numeric(as.character(accident.cords$longitude)), lat = as.numeric(as.character(accident.cords$latitude)), icon = crashIcon)

#potholes 

m <- m %>%  addMarkers(lng = potholes$lon, lat = potholes$lat, icon = bikehIcon) 
