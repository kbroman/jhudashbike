# getting lat and long with ggmap::geocode
library(ggmap)
baltimore <- geocode("Baltimore,MD", source="google")

# simple plot of Baltiomre
library(leaflet)
leaflet() %>%
    setView(lng= -76.6121893, lat=39.2903848, zoom=13) %>%
    addProviderTiles("CartoDB.Positron")

# baltimore city boundary
bdy <- matrix(c(-76.7113,39.372, -76.5297,39.372, -76.5299,39.2096, -76.5497,39.1972,
                -76.5837,39.2081, -76.6116,39.2344, -76.7112,39.2778, -76.7113,39.372), ncol=2, byrow=TRUE)
bdy <- as.data.frame(bdy)
colnames(bdy) <- c("lon", "lat")

# baltimore city boundary on the map
leaflet() %>%
    fitBounds(min(bdy$lon), min(bdy$lat), max(bdy$lon), max(bdy$lat)) %>%
    addProviderTiles("CartoDB.Positron") %>%
    addPolygons(lng=bdy$lon, lat=bdy$lat)

# points on a map
load("data/tows.RData") # example data
leaflet() %>%
    fitBounds(min(bdy$lon), min(bdy$lat), max(bdy$lon), max(bdy$lat)) %>%
    addProviderTiles("CartoDB.Positron") %>%
    addCircleMarkers(lng=tows$lon, lat=tows$lat,
                     popup=paste0("$", tows$charge, "\n", tows$address),
                     fillOpacity=0.5,
                     color=ifelse(!is.na(tows$stolen) & tows$stolen==1, "Orchid", "slateblue"),
                     radius=tows$charge/130+1)

leaflet() %>%
    fitBounds(min(bdy$lon), min(bdy$lat), max(bdy$lon), max(bdy$lat)) %>%
    addProviderTiles("CartoDB.Positron") %>%
    addPolygons(lng=bdy$lon, lat=bdy$lat)

# points on a map + baltimore boundary
leaflet() %>%
    fitBounds(min(bdy$lon), min(bdy$lat), max(bdy$lon), max(bdy$lat)) %>%
    addProviderTiles("CartoDB.Positron") %>%
    addCircleMarkers(lng=tows$lon, lat=tows$lat,
                     popup=paste0("$", tows$charge, "\n", tows$address),
                     fillOpacity=0.5,
                     color=ifelse(!is.na(tows$stolen) & tows$stolen==1, "Orchid", "slateblue"),
                     radius=tows$charge/130+1) %>%
    addPolygons(lng=bdy$lon, lat=bdy$lat,
                fill=FALSE, color="darkslateblue", opacity=0.4, weight=2)

# click on/off the stolen/not
stolen <- !is.na(tows$stolen) & tows$stolen==1
leaflet() %>%
    fitBounds(min(bdy$lon), min(bdy$lat), max(bdy$lon), max(bdy$lat)) %>%
    addPolygons(lng=bdy$lon, lat=bdy$lat,
                fill=FALSE, color="darkslateblue", opacity=0.4, weight=2) %>%
    addProviderTiles("CartoDB.Positron", group="CartoDB") %>%
    addProviderTiles("Stamen.TonerLite", group="TonerLite") %>%
    addProviderTiles("Stamen.Watercolor", group="Watercolor") %>%
    addCircleMarkers(lng=tows$lon[stolen], lat=tows$lat[stolen],
                     popup=paste0("$", tows$charge[stolen], "\n", tows$address[stolen]),
                     fillOpacity=0.5, color="Orchid",
                     radius=tows$charge[stolen]/130+1, group="Stolen") %>%
    addCircleMarkers(lng=tows$lon[!stolen], lat=tows$lat[!stolen],
                     popup=paste0("$", tows$charge[!stolen], "\n", tows$address[!stolen]),
                     fillOpacity=0.5, color="slateblue",
                     radius=tows$charge[!stolen]/130+1, group="Not stolen") %>%
    addLayersControl(baseGroups=c("CartoDB", "TonerLite", "Watercolor"),
                     overlayGroups=c("Stolen", "Not stolen"),
                     options=layersControlOptions(collapsed=FALSE))

# points on a map, clustering closely-spaced points
# (I don't really like this)
leaflet() %>%
    fitBounds(min(bdy$lon), min(bdy$lat), max(bdy$lon), max(bdy$lat)) %>%
    addProviderTiles("CartoDB.Positron") %>%
    addPolygons(lng=bdy$lon, lat=bdy$lat,
                fill=FALSE, color="darkslateblue", opacity=0.4, weight=2) %>%
    addCircleMarkers(lng=tows$lon, lat=tows$lat,
                     popup=paste0("$", tows$charge, "\n", tows$address),
                     fillOpacity=0.5,
                     color="#444", radius=3,
                     clusterOptions=markerClusterOptions())
