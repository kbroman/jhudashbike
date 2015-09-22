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
outdir = file.path(homedir, "clean_data")

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

fnames = file.path(datadir, 
    paste0(codes, ".csv"))
names(fnames) = codes
icode = codes[1]
    fname = fnames[icode]

for (icode in codes){
    fname = fnames[icode]
    df = read.csv(fname, 
            as.is=TRUE)
    all_data[[icode]] = df
    print(icode) 
}

max_n = sapply(all_data, nrow)
all_data = all_data[ max_n > 0]

all_ncols = sapply(all_data, ncol)
cn = lapply(all_data, colnames)
all_cn = sort(unique(unlist(cn)))

all_df = llply(all_data, function(x){
    cnx = colnames(x)
    icn = setdiff(all_cn,cnx) 
    for (iicn in seq_along(icn)){
        x[, icn[iicn]] = NA
    }
    x
})
all_df = do.call("rbind", all_df)
all_df$lon[ is.na(all_df$lon)] = all_df$long[ is.na(all_df$lon)]
all_df$long = NULL
all_df$i = NULL


write.csv(all_df, file = file.path(datadir, 
    "All_Hazards.csv"), row.names = FALSE)

df = all_df[, c("lat", "lon", 
    "code", "codedescription")]
df = df[ !(is.na(df$lat) | is.na(df$lon)), ]
rownames(df) = NULL
write.csv(all_df, file = file.path(outdir, 
    "Hazards.csv"), row.names = FALSE)

