# analysis of hazards

source("counts2paths.R")

# load hazard data and create pts matrix
haz <- data.table::fread("../clean_data/Hazards.csv", data.table=FALSE)
haz_pts <- cbind(lng=haz$lon, lat=haz$lat)
no_missing <- rowSums(is.na(haz_pts))==0
haz_pts <- haz_pts[no_missing,]
haz <- haz[no_missing,]

# drop hazards points not in boundary
in_city <- points.in.baltimore(haz_pts[,"lng"], haz_pts[,"lat"])
haz_pts <- haz_pts[in_city,]
haz <- haz[in_city,]

system.time(haz_dpath <- mclapply(seq(along=streets),
                                  function(i) find_close_pts2path(haz_pts, streets[[i]]),
                                  mc.cores=8))

# street length in meters
streetL <- unlist(mclapply(seq(along=streets), function(i) find_length(streets[[i]]), mc.cores=8))*1000

# counts within 10 m
haz_counts <- sapply(haz_dpath, function(a) sum(a[,1] < 0.01))

# save results
save(haz_counts, haz_dpath, file="haz_counts.RData")

# scatterplot of relative count vs street length
broman::grayplot(streetL,counts/(streetL+9), cex=0.5, pch=16, las=1, col="slateblue",
     ylab="relative count", xlab="block length (m)")
broman::grayplot(streetL,counts/(streetL+50), cex=0.5, pch=16, las=1, col="slateblue",
     ylab="relative count", xlab="block length (m)")
broman::grayplot(streetL,counts, cex=0.5, pch=16, las=1,
     ylab="count", xlab="block length (m)", col=ifelse(counts/(streetL+50) > 0.1, "violetred", "slateblue"))

source("plots.R")
plot_paths(paths=streets[counts/(streetL+9) > 0.5])
plot_paths(paths=streets[counts/(streetL+50) > 0.1])
