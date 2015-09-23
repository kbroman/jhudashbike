# analysis of hazards, accidents, crimes


source("counts2paths.R")

# load data and create pts matrix
haz_acc_cr <- data.table::fread("../clean_data/Hazards_Accidents_Crimes.csv", data.table=FALSE)
hac_pts <- haz_acc_cr[,2:1]
colnames(hac_pts) <- c("lng", "lat")

system.time(hac_dpath <- mclapply(seq(along=streets),
                                  function(i) find_close_pts2path(hac_pts, streets[[i]]),
                                  mc.cores=8))

# street lenght in meters
streetL <- unlist(mclapply(seq(along=streets), function(i) find_length(streets[[i]]), mc.cores=8))*1000

# counts within 10 m
hac_counts <- sapply(hac_dpath, function(a) sum(a[,1] < 0.01))

# save results
save(hac_counts, hac_dpath, file="hac_counts.RData")

# scatterplot of relative count vs street length
broman::grayplot(streetL,hac_counts/(streetL+9), cex=0.5, pch=16, las=1, col="slateblue",
     ylab="relative count", xlab="block length (m)")
broman::grayplot(streetL,hac_counts/(streetL+50), cex=0.5, pch=16, las=1, col="slateblue",
     ylab="relative count", xlab="block length (m)")
broman::grayplot(streetL,hac_counts, cex=0.5, pch=16, las=1,
     ylab="count", xlab="block length (m)", col=ifelse(hac_counts/(streetL+50) > 0.1, "violetred", "slateblue"))

source("plots.R")
plot_paths(paths=streets[hac_counts > 15])
