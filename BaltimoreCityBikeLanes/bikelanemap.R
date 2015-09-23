#############################################################
## set the data directory 
#############################################################

data.dir <- '/Users/elizabethsweeney/Dropbox/JHUDASH/'

#############################################################
## load the data
#############################################################

bike.lane.data <- read.csv('Bike_Lanes.csv')
bike.lane.data$path <- as.numeric(bike.lane.data$name)

#############################################################
## remove blocks with no address
#############################################################

bike.lane.data$block[as.character(bike.lane.data$block)==" "] <- NA
index.no.block <- is.na(bike.lane.data$block)
bike.lane.data$is.na <- index.no.block 
bike.lane.data <- bike.lane.data[bike.lane.data$is.na  == FALSE, ]

#############################################################
## load necessary libraries 
#############################################################

library(ggmap)
library(leaflet)
library(plyr)
library(rgdal)
library(maps)


#############################################################
## Get the street locations 
#############################################################
location <- apply(as.matrix(bike.lane.data$block), 2, function(x) paste0(x, ', Baltimore, MD')) 
my.map <- geocode(location, source = 'google')


bike.lane.data <- cbind(bike.lane.data, my.map)


#############################################################
# baltimore city boundary
#############################################################

bdy <- matrix(c(-76.7113,39.372, -76.5297,39.372, -76.5299,39.2096, -76.5497,39.1972,
                -76.5837,39.2081, -76.6116,39.2344, -76.7112,39.2778, -76.7113,39.372), ncol=2, byrow=TRUE)
bdy <- as.data.frame(bdy)
colnames(bdy) <- c("lon", "lat")

#############################################################
##add the bike routes 
#############################################################

bike.paths <- lapply(unique(bike.lane.data$path), function(x) cbind(bike.lane.data$lon, bike.lane.data$lat)[bike.lane.data$path == x,])

sort.my.paths <- function(matrix){
matrix <- as.matrix(matrix)	
return(matrix[sort(matrix[,1], index.return = TRUE)$ix,])
}

bike.paths <- lapply(bike.paths, function(x) sort.my.paths(x))
bike.paths.length <- unlist(lapply(bike.paths, function(x) length(x)))


m <- leaflet() %>%
    fitBounds(min(bdy$lon), min(bdy$lat), max(bdy$lon), max(bdy$lat)) %>%
    addProviderTiles("CartoDB.Positron") 
remove <- c( 1:length(bike.paths.length))[bike.paths.length/2 == 1]
bike.paths <- bike.paths[-remove]

for(i in 1:length(bike.paths)){
	m <- m %>% addMarkers(lng=as.matrix(bike.paths[[i]])[,1], lat=as.matrix(bike.paths[[i]])[,2]) 
   ## addPolylines(lng=as.matrix(bike.paths[[i]])[,1], lat=as.matrix(bike.paths[[i]])[,2])
    print(i) 	
}




