##############################
# This will Plot Maps
##############################
rm(list=ls())
rerun = FALSE
# homedir = datadir = "~/"
homedir = path.expand("~/Dropbox/jhudash/jhudashbike")
datadir = file.path(homedir, "Arrests")
outdir = file.path(homedir, "clean_data")
progdir = file.path(homedir, "programs")
source(file.path(progdir, "points.in.baltimore.R"))

load(
    file.path(datadir, 
    "arrests.rda"))

arrests$ChargeDescription = as.character(
    arrests$ChargeDescription)

ss = strsplit(arrests$ChargeDescription, 
    "||", fixed = TRUE)
ss = lapply(ss, trimws)
ss = sapply(ss, `[`, 2)

keep_type = c("Theft", "Handgun Violation", 
    "Hgv", "Armed Robbery", "Robbery", "B&E")

keep = rep(FALSE, nrow(arrests))
keep[ grep("ssault", ss)] = TRUE
keep[ grep("urglary", ss)] = TRUE
keep[ grep("Deadly", ss)] = TRUE
keep[ grep("obbery", ss)] = TRUE
keep[ ss %in% keep_type ] = TRUE

df = arrests[keep, ]

keep = points.in.baltimore(df$long, df$lat)
balt_df = df[ keep, ]

balt_df$lon = balt_df$long
balt_df$address = balt_df$ArrestLocation
balt_df$description = balt_df$ChargeDescription
balt_df = balt_df[, c("lat", "lon", 
    "address", "description")]
write.csv(balt_df, 
    file = file.path(outdir, "Violent_Arrests.csv"),
    row.names = FALSE)