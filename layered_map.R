library(png) 
library(ggmap)
library(leaflet)
library(plyr)
library(rgdal)
library(maps)
library(magrittr)

### some functions we need 

plot_paths <-
    function(map, paths, col="violetred", weight=2, popup=NULL, opacity=1, group="main")
{
    library(leaflet)
    # baltimore boundary
    bdy <- matrix(c(-76.7113,39.372, -76.5297,39.372, -76.5299,39.2096, -76.5497,39.1972,
                -76.5837,39.2081, -76.6116,39.2344, -76.7112,39.2778, -76.7113,39.372), ncol=2, byrow=TRUE)
    bdy <- as.data.frame(bdy)
    colnames(bdy) <- c("lon", "lat")

    if(missing(map))
        map <- leaflet() %>%
            fitBounds(min(bdy$lon), min(bdy$lat), max(bdy$lon), max(bdy$lat)) %>%
                addProviderTiles("CartoDB.Positron") %>%
                    addPolygons(lng=bdy$lon, lat=bdy$lat,
                                fill=FALSE, color="darkslateblue", opacity=0.4, weight=2)

    for(i in seq(along=paths)) {
        if("path1" %in% names(paths[[i]])) {
            map %<>% addPolylines(lng=paths[[i]]$path1$lng,
                                  lat=paths[[i]]$path1$lat, opacity=opacity,
                                  color=col, weight=weight, popup=popup[i], group=group)
            if("path2" %in% names(paths[[i]])) {
                map %<>% addPolylines(lng=paths[[i]]$path2$lng,
                                      lat=paths[[i]]$path2$lat, opacity=opacity,
                                      color=col, weight=weight, popup=popup[i], group=group)
            }
        }
        else {
            map %<>% addPolylines(lng=paths[[i]]$lng,
                                  lat=paths[[i]]$lat, opacity=opacity,
                                  color=col, weight=weight, popup=popup[i], group=group)
        }

    }

    map
}

# plot a set of points
#    if map is provided, points are added to it
plot_pts <-
    function(map, pts, col="slateblue", weight=2, opacity=0.1, popup=NULL, radius=2, group="main")
{
    library(leaflet)
    # baltimore boundary
    bdy <- matrix(c(-76.7113,39.372, -76.5297,39.372, -76.5299,39.2096, -76.5497,39.1972,
                -76.5837,39.2081, -76.6116,39.2344, -76.7112,39.2778, -76.7113,39.372), ncol=2, byrow=TRUE)
    bdy <- as.data.frame(bdy)
    colnames(bdy) <- c("lon", "lat")

    if(missing(map))
        map <- leaflet() %>%
            fitBounds(min(bdy$lon), min(bdy$lat), max(bdy$lon), max(bdy$lat)) %>%
                addProviderTiles("CartoDB.Positron") %>%
                    addPolygons(lng=bdy$lon, lat=bdy$lat,
                                fill=FALSE, color="darkslateblue", opacity=0.4, weight=2)

    for(nam in c("long", "lon")) {
        if(nam %in% colnames(pts)) {
            cn <- colnames(pts)
            cn[cn==nam] <- "lng"
            colnames(pts) <- cn
        }
    }

    for(i in seq(along=pts))
        map %<>% addCircleMarkers(lng=pts[,"lng"],
                                  lat=pts[,"lat"],
                                  color=col, weight=weight,
                                  fillOpacity=opacity, opacity=opacity,
                                  popup=popup, radius=radius, group=group)

    map
}

### end of functions 

##load in the data 

clean.data.dir <-  '/Users/elizabethsweeney/Dropbox/Elizabeth_Sweeney_Documents/Current_Projects/jhudashbike/clean_data/'
block.dir <- '/Users/elizabethsweeney/Dropbox/Elizabeth_Sweeney_Documents/Current_Projects/jhudashbike/counts2paths/'
street.dir <- '/Users/elizabethsweeney/Dropbox/Elizabeth_Sweeney_Documents/Current_Projects/jhudashbike/BaltimoreStreets/'

load(paste0(clean.data.dir, 'bikepaths.rda'))
acc.arrest.haz.data <- read.csv(paste0(clean.data.dir , 'Hazards_Accidents_Crimes.csv'))
hazard <- acc.arrest.haz.data[acc.arrest.haz.data$type == 'Hazard',]
arrest <- acc.arrest.haz.data[acc.arrest.haz.data$type == 'Arrest',]
accident <- acc.arrest.haz.data[acc.arrest.haz.data$type == 'Accident',]
load(paste0(block.dir, 'acc_counts.RData'))
load(paste0(block.dir, 'haz_counts.RData'))
load(paste0(block.dir, 'varr_counts.RData'))
streets <- readRDS(paste0(street.dir, "streets.rds"))

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
                    , group="Hazard Events", radius = 1) %>%
    addCircleMarkers(lng=acc.arrest.haz.data$lon[acc.arrest.haz.data$type == 'Arrest'], lat=acc.arrest.haz.data$lat[acc.arrest.haz.data$type == 'Arrest'],
                     fillOpacity=0.5, color="slateblue", group="Arrest Events", radius = 1) %>%
    addCircleMarkers(lng=acc.arrest.haz.data$lon[acc.arrest.haz.data$type == 'Accident'], lat=acc.arrest.haz.data$lat[acc.arrest.haz.data$type == 'Accident'],
                     fillOpacity=0.5, color="orange", group="Accident Events", radius = 1) 






m <- m %>% plot_paths(paths=streets[acc_counts > 4], opacity=0.3, weight=4, group="Accident Blocks") %>%
    plot_paths(paths=streets[haz_counts > 15], opacity=0.3, col="slateblue", weight=4, group="Hazard Block") %>%
    plot_paths(paths=streets[varr_counts > 15], opacity=0.3, col="green", weight=4, group="Arrest Events") %>%
        addLayersControl(baseGroups=c("CartoDB"),
                     overlayGroups=c("Hazard Events", "Arrest Events", "Accident Events" , "Accident Blocks", "Hazard Block", "Arrest Block"),
                     options=layersControlOptions(collapsed=FALSE))



