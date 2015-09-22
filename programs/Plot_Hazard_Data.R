##############################
# This will Plot Maps
##############################
rm(list=ls())
library(methods)
library(ggmap)
library(leaflet)
rerun = FALSE
# homedir = datadir = "~/"
homedir = path.expand("~/Dropbox/jhudash/jhudashbike")
datadir = file.path(homedir, "clean_data")
outdir = file.path(homedir, "results")
progdir = file.path(homedir, "programs")
source(file.path(progdir, "points.in.baltimore.R"))

#################################
# Potholes and hazards
#################################
hazards = read.csv(file.path(datadir, "Hazards.csv"), 
    as.is = TRUE)
hazards = hazards[ hazards$code %in% c("POTHOLES"),]
keep = points.in.baltimore(hazards$lon, hazards$lat)
haz = hazards[ keep, ]
haz$type = "Hazard"
haz = haz[, c("lat", "lon", "type")]

#################################
# Violent Crimes
#################################
arr = read.csv(file.path(datadir, 
    "Violent_Arrests.csv"), 
    as.is = TRUE)
keep = points.in.baltimore(arr$lon, arr$lat)
arrests = arr[ keep, ]
arrests$type = "Arrest"
arrests = arrests[, c("lat", "lon", "type")]

#################################
# Accidents
#################################
load(file.path(datadir, 
    "accidents.rda"))
accident.cords$longitude = as.numeric(
    as.character(
    accident.cords$longitude
    )
)
accident.cords$latitude = as.numeric(
    as.character(
    accident.cords$latitude
    )
)
keep = points.in.baltimore(accident.cords$longitude, 
    accident.cords$latitude)
acc = accident.cords[ keep, ]
acc$type = "Accident"
acc = acc[, c("latitude", "longitude", "type")]
colnames(acc) = c("lat", "lon", "type")



df = rbind(haz, arrests, acc)

# from = "2120 Moyer Street, Baltimore MD"
from = "Bank St and Conkling St, Baltimore maryland"
# to = "1900 Thames St, Baltimore MD"
to = "802 S Caroline St, Baltimore MD"
legs_df <- route(from,
    to, 
    alternatives = TRUE
    )

# fname = file.path(datadir, "All_Hazards.csv")
# df = read.csv(
#     fname,
#     as.is=TRUE)
if (!"route" %in% colnames(legs_df)){
    legs_df$route = "A"
}
map = qmap("Baltimore MD", zoom = 13)

map + geom_leg(aes(x = startLon, 
y = startLat, xend = endLon, 
yend = endLat, colour = route), data = legs_df)

