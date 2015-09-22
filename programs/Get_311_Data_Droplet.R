##############################
# This will access 311 customer service requests
# For accidents and street quality
##############################
rm(list=ls())
library(methods)
library(plyr)
library(dplyr)
library(jsonlite)
library(stringr)
library(httr)
library(ggmap)
rerun = FALSE
homedir = datadir = "~/"

socrata_app_token = "F9njoSZggFjFMsjX9NDh3r8fe"
get.lat.long.baltimore <- function(block, 
    source = "google", ...){
    print(length(block))
  location <- paste0(block, ', Baltimore MD')
  my.map = geocode(location, 
    source = source, ...)
#   my.map <- lapply(location, geocode)
  return(my.map)
}
# Dataset from data.baltimore.gov
coder = function(codes, geo = FALSE){
    stub = "http://data.baltimorecity.gov/resource"
    json = paste0(stub, "/q7s2-a6pd.", 
        ifelse(geo, "geojson", "json"), "?")
    page = paste0(json, "$limit=50000&$$app_token=", 
        socrata_app_token)

    p = paste0("'", paste(codes,
        collapse = "', '", sep= ""), "'")
    page = paste0(page, paste0("&$where=code in(", p, ")"))
    page = URLencode(page)

    g = GET(page)
    fromJSON(as.character(g))
}
all_codes = c('BGESLPIN', 'BGESTLI1', 'BGESTLI2', 
    'BGESTLI3', 'ECCSLOW', 'FTRH', 'FOBRBRIT', 
    'FORESTR3', 'FORESTR2', 'HCDSNOW', 'ZTRMDEBR', 
    'TRMMAJOR', 'TRMPICKU', 'ICYCONDI', 'STEELPL2', 
    'STREETL2', 'TRMSLPMS', 'STREETL6', 'STREETL5', 
    'STREETL3', 'STREETRE', 'SIGNFADE', 'SIGNMISS', 
    'WWHYDRAN', 'WWSURFAC', 'WWSEWERS', 'WWSTORM6', 
    'WWSTORM2', 'WWSTORMS', 'WWWATERP', 'WWSURFA1', 
    'WWWATE20', 'WWSREPST', 'WWSREPPE', 'WWWATERM', 
    'STEELPLA', "POTHOLES", "STREETRE", 
    "SIGNMISS", "BGESTLI1")
codes = unique(all_codes)

fnames = file.path(datadir, 
    paste0(codes, ".csv"))

all_data = vector(mode = "list", 
    length = length(codes))
names(all_data) = codes

iid <- as.numeric(Sys.getenv("SGE_TASK_ID"))
if (is.na(iid)) iid <- 37

icode = codes[iid]
# for (icode in codes){
    # if (!file.exists(fname) | rerun){    
        df = coder(icode)
        df$methodreceived = NULL
        df = unique(df)
        df$address = str_trim(df$address)
        n = 2500
        # if (nrow(df) > n){
            ind = seq(1, ceiling(nrow(df)/n))
            df$i = rep(
                ind, 
                each = n)[seq(nrow(df))]
            iind = 5
            df$lat = df$lon = NA
            # for (iind in ind){
            fname = file.path(datadir, 
                paste0(icode, "_", iind, ".csv")) 

                log_ind = df$i == iind
                ddf = df[ log_ind, ]
                addresses = get.lat.long.baltimore(
                    ddf$address,
                    source = "google"
                    )
                ddf$lat = addresses$lat
                ddf$lon = addresses$lon

                write.csv(x = ddf, 
                    file = fname, 
                    row.names = FALSE)  
