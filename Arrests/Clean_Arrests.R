##############################
# This will Plot Maps
##############################
rm(list=ls())
rerun = FALSE
# homedir = datadir = "~/"
homedir = path.expand("~/Dropbox/jhudash/jhudashbike")
datadir = file.path(homedir, "Arrests")
outdir = file.path(homedir, "results")

load(file.path(datadir, "arrests.rda"))