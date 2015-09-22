pot.hole.dir <- '/Users/elizabethsweeney/Dropbox/Elizabeth_Sweeney_Documents/Current_Projects/jhudashbike/data/'
street.dir <- '/Users/elizabethsweeney/Dropbox/Elizabeth_Sweeney_Documents/Current_Projects//jhudashbike/BaltimoreStreets/'

streets <- readRDS(paste0(street.dir, "streets.rds"))
potholes_5 <- read.csv(paste0(pot.hole.dir, 'POTHOLES_5.csv'))



#############################################################
## remove blocks with no address
#############################################################

potholes_5$StreetAddress[as.character(potholes_5$StreetAddress)==" "] <- NA
index.no.block <- is.na(potholes_5$StreetAddress)
potholes_5$is.na <- index.no.block 
potholes_5<- potholes_5[potholes_5$is.na  == FALSE, ]

key.streets <- unlist(lapply(streets, function (x) x$name))
key.numbers <- unlist(lapply(streets, function (x) x$name))

pothole.street.number <- lapply(as.character(potholes_5$StreetAddress), function(x) as.numeric(gsub("([0-9]+).*$", "\\1", x)))
unlist(lapply(is.na(pothole.street.number, )))
pothole.street <- lapply(as.character(potholes_5$StreetAddress), function(x) gsub("[0-9]", "", x))


pothole.street == 