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
library(RSocrata)
library(data.table)
library(stringr)
library(ggmap)
rerun = FALSE
# homedir = datadir = "~/"
homedir = path.expand("~/Dropbox/jhudash/jhudashbike")
datadir = file.path(homedir, "data")
outdir = file.path(homedir, "results")

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

icode = codes[iid]
for (icode in codes){
    fname = file.path(datadir, 
        paste0(icode, ".csv"))
    if (!file.exists(fname) | rerun){    
        df = coder(icode)
        df$methodreceived = NULL
        df = unique(df)
        df$address = str_trim(df$address)
        n = 2500
        if (nrow(df) > n){
            ind = seq(1, ceiling(nrow(df)/n))
            df$i = rep(
                ind, 
                each = n)[seq(nrow(df))]
            iind = 1
            df$lat = df$lon = NA
            for (iind in ind){
                log_ind = df$i == iind
                ddf = df[ log_ind, ]
                addresses = get.lat.long.baltimore(
                    ddf$address,
                    source = "dsk"
                    )
                df$lat[log_ind] = addresses$lat
                df$long[log_ind] = addresses$lon
            }
        } else {
            addresses = get.lat.long.baltimore(
                df$address,
                    source = "dsk"
                )
            df = cbind(df, addresses)
        }
        write.csv(x = df, 
            file = fname, 
            row.names = FALSE)  
    } else {
        df = read.csv(fname, 
            as.is=TRUE)
    }
}