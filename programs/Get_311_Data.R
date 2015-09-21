##############################
# This will access 311 customer service requests
# For accidents and street quality
##############################
rm(list=ls())
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
homedir = path.expand("~/Dropbox/jhudash/jhudashbike")
datadir = file.path(homedir, "data")
outdir = file.path(homedir, "results")

socrata_app_token = readLines(
    file.path(homedir, "socrata_api_key.txt")
    )
get.lat.long.baltimore <- function(block, 
    source = "google", ...){
  location <- paste0(block, ' Baltimore, MD')
  my.map = geocode(location, 
    source = source, ...)
#   my.map <- lapply(location, geocode)
  return(my.map)
}
# Dataset from data.baltimore.gov
# Old dataset https://data.baltimorecity.gov/resource/9agw-sxsr.json
coder = function(codes, geo = FALSE){
    stub = "https://data.baltimorecity.gov/resource"
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

######################
# Download all the data
######################
fname = file.path(datadir, "Accidents_311.csv")
if (!file.exists(fname) | rerun){
    accident = coder("FICIMOVA")
    accident$methodreceived = NULL
    accident = unique(accident)
    accident$address = str_trim(accident$address)
    addresses = get.lat.long.baltimore(
        accident$address
        )
    accident = cbind(accident, addresses)
    write.csv(x = accident, 
        file = fname, 
        row.names = FALSE)
}

all_data = vector(mode = "list", 
    length = length(codes))
names(all_data) = codes
icode = codes[3]
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
                    ddf$address
                    )
                df$lat[log_ind] = addresses$lat
                df$long[log_ind] = addresses$lon
            }
        } else {
            addresses = get.lat.long.baltimore(
                df$address
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
    all_data[[icode]] = df
    print(icode)
}
    # all_data = llply(codes, coder, 
    #     .progress = "text")
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






# # devtools::install_github("Chicago/RSocrata")
# df = read.socrata(page)

# Socrata API - 
# Data was from https://data.baltimorecity.gov/resource/9agw-sxsr.json
# fname = file.path(datadir, 
#     "311_Customer_Service_Requests.csv")
# df = fread(fname, 
#            colClasses = c(rep("character", 16)) )



# keepcodes = c("POTHOLES", "FICIMOVA")
# stub = "http://311.baltimorecity.gov/open311/v2"
# u <- file.path(stub, "services.json?jursdiction_id=baltimorecity.gov")
# ## test data set
# ff <- url(u)
# x <- readLines(ff)
# close(ff)
# J <- fromJSON(x)
# df = lapply(J, as.data.frame)
# df = do.call("rbind", df)
# unique(J$service_name)


# API Requests
# api_key_311 = readLines("311_api_key.txt")
# service_code = "4e39a3abd3e2c20ed800001d"
# u <- paste0("http://311.baltimorecity.gov/open311/v2/requests.json?api_key=", api_key_311, 
#             "&jurisdiction_id=baltimorecity.gov")
# ## test data set
# ff <- url(u)
# x <- readLines(ff)
# close(ff)
# J <- fromJSON(x)
# 
# 
# https://api.city.gov/dev/v2/services.xml?jurisdiction_id=city.gov

