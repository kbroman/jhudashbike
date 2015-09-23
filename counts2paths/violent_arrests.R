# analysis of violent arrests

source("counts2paths.R")

# load accident data and create pts matrix
violarr <- data.table::fread("../clean_data/Violent_Arrests.csv", data.table=FALSE)
varr_pts <- cbind(lng=as.numeric(violarr$lon), lat=as.numeric(violarr$lat))

system.time(varr_dpath <- mclapply(seq(along=streets),
                                  function(i) find_close_pts2path(varr_pts, streets[[i]]),
                                  mc.cores=8))

# street length in meters
streetL <- unlist(mclapply(seq(along=streets), function(i) find_length(streets[[i]]), mc.cores=8))*1000

# counts within 10 m
varr_counts <- sapply(varr_dpath, function(a) sum(a[,1] < 0.01))

# save results
save(varr_counts, varr_dpath, file="varr_counts.RData")

# scatterplot of relative count vs street length
broman::grayplot(streetL,varr_counts/(streetL+9), cex=0.5, pch=16, las=1, col="slateblue",
     ylab="relative count", xlab="block length (m)")
broman::grayplot(streetL,varr_counts/(streetL+50), cex=0.5, pch=16, las=1, col="slateblue",
     ylab="relative count", xlab="block length (m)")
broman::grayplot(streetL,varr_counts, cex=0.5, pch=16, las=1,
     ylab="count", xlab="block length (m)", col=ifelse(varr_counts/(streetL+50) > 0.04, "violetred", "slateblue"))

source("plots.R")
plot_paths(paths=streets[varr_counts > 15])
