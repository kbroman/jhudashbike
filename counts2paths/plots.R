# plot a set of paths
#   if map is provided, paths are added to it
plot_paths <-
    function(map, paths, col="violetred", weight=2, popup=NULL)
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

    for(i in seq(along=paths))
        map %<>% addPolylines(lng=paths[[i]]$path1$lng,
                              lat=paths[[i]]$path1$lat,
                              color=col, weight=weight, popup=popup[i])

    map
}

# plot a set of points
#    if map is provided, points are added to it
plot_pts <-
    function(map, pts, col="slateblue", weight=2, opacity=0.1, popup=NULL, radius=2)
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
                                  popup=popup, radius=radius)

    map
}
