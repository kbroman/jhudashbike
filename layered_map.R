library(png)
library(ggmap)
library(leaflet)
library(plyr)
library(rgdal)
library(maps)
library(magrittr)
library(sp)

# dashdir = "/Users/elizabethsweeney/Dropbox/Elizabeth_Sweeney_Documents/Current_Projects/jhudashbike/"
#dashdir = "~/Dropbox/jhudash/jhudashbike"
dashdir = "."
dashdir = path.expand(dashdir)

clean.data.dir <-  file.path(dashdir, 'clean_data')
block.dir <- file.path(dashdir, 'counts2paths')
street.dir <- file.path(dashdir, 'BaltimoreStreets')


### some functions we need

plot_paths <-
    function(map, paths, col="violetred", weight=4, popup=NULL, opacity=0.8, group="main")
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


load(file.path(clean.data.dir, 'bikepaths.rda'))
acc.arrest.haz.data <- read.csv(file.path(clean.data.dir , 'Hazards_Accidents_Crimes.csv'))
hazard <- acc.arrest.haz.data[acc.arrest.haz.data$type == 'Hazard',]
arrest <- acc.arrest.haz.data[acc.arrest.haz.data$type == 'Arrest',]
accident <- acc.arrest.haz.data[acc.arrest.haz.data$type == 'Accident',]
load(file.path(block.dir, 'acc_counts.RData'))
load(file.path(block.dir, 'haz_counts.RData'))
load(file.path(block.dir, 'varr_counts.RData'))
streets <- readRDS(file.path(street.dir, "streets.rds"))

ss = SpatialPointsDataFrame(
  coords = acc.arrest.haz.data[, c("lon", "lat")],
  data = acc.arrest.haz.data)
# baltimore city boundary

bdy <- matrix(c(-76.7113,39.372, -76.5297,39.372, -76.5299,39.2096, -76.5497,39.1972,
                -76.5837,39.2081, -76.6116,39.2344, -76.7112,39.2778, -76.7113,39.372), ncol=2, byrow=TRUE)
bdy <- as.data.frame(bdy)
colnames(bdy) <- c("lon", "lat")


# baltimore city map

m <- leaflet() %>% setView(lng=mean(range(bdy$lon)), lat=mean(range(bdy$lat)), zoom=12) %>%
    addProviderTiles("CartoDB.Positron") %>%
    addPolygons(lng=bdy$lon, lat=bdy$lat, fillOpacity=0, color="#999", weight=3)

# bike paths

for(i in 1:length(bike.paths)){
    m <- m %>% addPolylines(lng=as.matrix(bike.paths[[i]])[,1], lat=as.matrix(bike.paths[[i]])[,2],
                            group="Bike Paths")
#    print(i)
}


# baltimore city map


cols = c("#F012BE", "#444444",  "#FF851B", "#0074D9")

types = sort(unique(
  as.character(acc.arrest.haz.data$type)))
types = c(types,
  "Bike Lane")
types = factor(types, levels = types)
pal <- colorFactor(
  palette = cols,
  domain = types
)

# m <- m %>%
#   addCircleMarkers(
#   fillOpacity=0.5, color=~pal(type),
#   data = ss,
#   group = ~ paste0(as.character(type), " Events"),
#   , radius = 1)



m <- m %>% addCircleMarkers(lng=acc.arrest.haz.data$lon[acc.arrest.haz.data$type == 'Hazard'], lat=acc.arrest.haz.data$lat[acc.arrest.haz.data$type == 'Hazard'], opacity=0.5,
                     fillOpacity=0.5, color=NA, fillColor=cols[3],
                    , group="Hazard Events", radius = 3) %>%
    addCircleMarkers(lng=acc.arrest.haz.data$lon[acc.arrest.haz.data$type == 'Arrest'], lat=acc.arrest.haz.data$lat[acc.arrest.haz.data$type == 'Arrest'], opacity=0.5,
                     fillOpacity=0.5, color=NA, fillColor=cols[2], group="Arrest Events", radius = 3) %>%
    addCircleMarkers(lng=acc.arrest.haz.data$lon[acc.arrest.haz.data$type == 'Accident'], lat=acc.arrest.haz.data$lat[acc.arrest.haz.data$type == 'Accident'], opacity=0.5,
                     fillOpacity=0.5, color=NA, fillColor=cols[1], group="Accident Events", radius = 3)

m <- m %>%
    plot_paths(paths=streets[haz_counts > 15], col=cols[3], group="Hazard Blocks") %>%
    plot_paths(paths=streets[varr_counts > 15], col=cols[2], group="Arrest Blocks") %>%
    plot_paths(paths=streets[acc_counts > 4], col = cols[1], group="Accident Blocks") %>%
        addLayersControl(
          # baseGroups=c("CartoDB"),
                     overlayGroups=c(
                      "Hazard Events", "Arrest Events", "Accident Events" ,
                      "Hazard Blocks", "Arrest Blocks", "Accident Blocks", "Bike Paths"),
                     options=layersControlOptions(collapsed=FALSE)) %>%
    addLegend(position = "topright",
      pal = pal,
      values = types,
      opacity = 1
    )




##############################################
# John code - condensing code
##############################################
# ss = SpatialPointsDataFrame(
#   coords = acc.arrest.haz.data[, c("lon", "lat")],
#   data = acc.arrest.haz.data)

# pal <- colorFactor(
#   palette = "YlGnBu",
#   domain = acc.arrest.haz.data$type
# )

# m <- m %>%
#   addCircleMarkers(
#   fillOpacity=0.5, color=~pal(type),
#   data = ss,
#   , radius = 1) %>%
#   addLegend(position = "topright",
#     pal = pal, values = acc.arrest.haz.data$type,
#     title = "Type of Problem",
#     opacity = 1
#   ) %>%
#     addLayersControl(baseGroups=c("CartoDB"),
#                      overlayGroups=c("Hazard", "Arrest", "Accident"),
#                      options=layersControlOptions(collapsed=FALSE))
