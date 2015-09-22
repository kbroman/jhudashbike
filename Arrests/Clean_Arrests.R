##############################
# This will Plot Maps
##############################
rm(list=ls())
rerun = FALSE
# homedir = datadir = "~/"
homedir = path.expand("~/Dropbox/jhudash/jhudashbike")
datadir = file.path(homedir, "Arrests")
outdir = file.path(homedir, "results")
progdir = file.path(homedir, "programs")
source("points.in.baltimore.R")
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

point.in.polygon(point.x, point.y, pol.x, )