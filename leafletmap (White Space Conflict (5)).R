library(png) 
library(ggmap)
library(leaflet)
library(plyr)
library(rgdal)
library(maps)




icon.dir <- '/Users/elizabethsweeney/Dropbox/Elizabeth_Sweeney_Documents/Current_Projects/jhudashbike/icons/'
data.dir <- '/Users/elizabethsweeney/Dropbox/Elizabeth_Sweeney_Documents/Current_Projects/jhudashbike/BaltimoreCityBikeLanes/'
bike.lane.data  <- read.csv(paste0(data.dir, 'Bike_Lanes_Geocoded.csv'))

accident.dir <- '/Users/elizabethsweeney/Dropbox/Elizabeth_Sweeney_Documents/Current_Projects/jhudashbike/BaltimoreCityAccidents/'
accident.cords <- read.csv(paste0(accident.dir, 'data_out.csv')) 


########################################################################################
## create an accident icon
########################################################################################

setwd('/Users/elizabethsweeney/Dropbox/Elizabeth_Sweeney_Documents/Current_Projects/jhudashbike/icons/')

height = 15
crashIcon <- makeIcon(
  iconUrl = "icon_fire.png",
  iconWidth = height, iconHeight = height)

########################################################################################
## format biking data
########################################################################################


bike.lane.data$path <- as.numeric(bike.lane.data$name)

## remove blocks with no address

bike.lane.data$block[as.character(bike.lane.data$block)==" "] <- NA
index.no.block <- is.na(bike.lane.data$block)
bike.lane.data$is.na <- index.no.block 
bike.lane.data <- bike.lane.data[bike.lane.data$is.na  == FALSE, ]


# baltimore city boundary


bdy <- matrix(c(-76.7113,39.372, -76.5297,39.372, -76.5299,39.2096, -76.5497,39.1972,
                -76.5837,39.2081, -76.6116,39.2344, -76.7112,39.2778, -76.7113,39.372), ncol=2, byrow=TRUE)
bdy <- as.data.frame(bdy)
colnames(bdy) <- c("lon", "lat")


##add the bike routes 


bike.paths <- lapply(unique(bike.lane.data$path), function(x) cbind(bike.lane.data$lon, bike.lane.data$lat)[bike.lane.data$path == x,])
bike.paths.length <- unlist(lapply(bike.paths, function(x) length(x)))
remove <- c( 1:length(bike.paths.length))[bike.paths.length/2 == 1]
bike.paths <- bike.paths[-remove]

sort.my.paths <- function(matrix){
matrix <- as.matrix(matrix)	
my.max <- max(var(matrix[,1]), var(matrix[,2]))
if(var(matrix[,1]) == my.max){
return(matrix[sort(matrix[,1], index.return = TRUE)$ix,])	
} else{
return(matrix[sort(matrix[,2], index.return = TRUE)$ix,])		
}
}

path.distances <- function(matrix){

distances <- (matrix[1:c(dim(matrix)[1] - 1),] - matrix[2:dim(matrix)[1],])
return(max(distances))
}

bike.paths.max.dist <- lapply(bike.paths, function(x) path.distances(x))
bike.paths <- lapply(bike.paths, function(x) sort.my.paths(x))


bike.paths <- bike.paths[ - c(sort(unlist(bike.paths.max.dist), index.return = TRUE, decreasing = TRUE)$ix[1:5])]


m <- leaflet() %>% fitBounds(min(bdy$lon), min(bdy$lat), max(bdy$lon), max(bdy$lat)) %>% addProviderTiles("CartoDB.Positron") 
remove <- c( 1:length(bike.paths.length))[bike.paths.length/2 == 1]
bike.paths <- bike.paths[-remove]

for(i in 1:length(bike.paths)){
	m <- m %>% addPolylines(lng=as.matrix(bike.paths[[i]])[,1], lat=as.matrix(bike.paths[[i]])[,2])
    print(i) 	
}




########################################################################################
## add the accidents 
########################################################################################



index.accidents  <- (accident.cords$longitude == '.' & accident.cords$latitude == '.')
accident.cords <- accident.cords[index.accidents == FALSE, ]

m <- m %>% fitBounds(min(bdy$lon), min(bdy$lat), max(bdy$lon), max(bdy$lat)) %>% addProviderTiles("CartoDB.Positron") %>% addMarkers(lng = as.numeric(as.character(accident.cords$longitude)), lat = as.numeric(as.character(accident.cords$latitude)), icon = crashIcon)


