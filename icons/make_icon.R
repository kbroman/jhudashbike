library(leaflet) 
data(quakes)

height = 15
greenLeafIcon <- makeIcon(
  iconUrl = "icon_fire.png",
  iconWidth = height, iconHeight = height)

leaflet(data = quakes[1:4,]) %>% addTiles() %>%
  addMarkers(~long, ~lat, icon = greenLeafIcon)
