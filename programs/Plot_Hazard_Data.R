##############################
# This will Plot Maps
##############################
rm(list=ls())
library(methods)
library(plyr)
library(dplyr)
library(jsonlite)
library(stringr)
library(httr)
library(RSocrata)
library(data.table)
library(stringr)
library(ggmap)
rerun = FALSE
# homedir = datadir = "~/"
homedir = path.expand("~/Dropbox/jhudash/jhudashbike")
datadir = file.path(homedir, "data")
outdir = file.path(homedir, "results")


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

