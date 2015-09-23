# analysis of accidents

source("counts2paths.R")

# load accident data and create pts matrix
load("../clean_data/accidents.rda")
fac2num <- function(a) as.numeric(as.character(a))
acc_pts <- cbind(lng=fac2num(accident.cords$longitude), lat=fac2num(accident.cords$latitude))

system.time(acc_dpath <- mclapply(seq(along=streets),
                                  function(i) find_close_pts2path(acc_pts, streets[[i]]),
                                  mc.cores=8))

# street length in meters
streetL <- unlist(mclapply(seq(along=streets), function(i) find_length(streets[[i]]), mc.cores=8))*1000

# counts within 10 m
acc_counts <- sapply(acc_dpath, function(a) sum(a[,1] < 0.01))

# save results
save(acc_counts, acc_dpath, file="acc_counts.RData")

# scatterplot of relative count vs street length
broman::grayplot(streetL,acc_counts/(streetL+9), cex=0.5, pch=16, las=1, col="slateblue",
     ylab="relative count", xlab="block length (m)")
broman::grayplot(streetL,acc_counts/(streetL+50), cex=0.5, pch=16, las=1, col="slateblue",
     ylab="relative count", xlab="block length (m)")
broman::grayplot(streetL,acc_counts, cex=0.5, pch=16, las=1,
     ylab="count", xlab="block length (m)", col=ifelse(acc_counts/(streetL+50) > 0.04, "violetred", "slateblue"))

source("plots.R")
plot_paths(paths=streets[acc_counts > 4]) %>%
           plot_paths(paths=streets[acc_counts/(streetL+50) > 0.04], col="slateblue")
