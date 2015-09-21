library(ggmap)
baltimore <- geocode("Baltimore,MD", source="google")


library(leaflet)
leaflet() %>%
    setView(lng= -76.6121893, lat=39.2903848, zoom=13) %>%
    addProviderTiles("CartoDB.Positron")

# baltimore city boundary
bdy <- matrix(c(-76.7113,39.372, -76.5297,39.372, -76.5299,39.2096, -76.5497,39.1972,
                -76.5837,39.2081, -76.6116,39.2344, -76.7112,39.2778, -76.7113,39.372), ncol=2, byrow=TRUE)
bdy <- as.data.frame(bdy)
colnames(bdy) <- c("lon", "lat")

leaflet() %>%
    fitBounds(min(bdy$lon), min(bdy$lat), max(bdy$lon), max(bdy$lat)) %>%
    addProviderTiles("CartoDB.Positron") %>%
    addPolygons(lng=bdy$lon, lat=bdy$lat)
