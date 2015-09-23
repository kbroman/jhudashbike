# common mapmyride routes
dir <- file.path("..", "routesfrommapmyride")
files <- list.files(dir)
routes <- vector("list", length(files))
for(i in seq(along=files))
    routes[[i]] <- data.table::fread(file.path(dir, files[i]), data.table=FALSE)

allroutes <- NULL
nam <- NULL
for(i in seq(along=routes)) {
    ur <- unique(routes[[i]]$route)
    for(r in seq(along=ur)) {
        tmp <- routes[[i]]
        tmp <- tmp[tmp$route==ur[r],]
        tmp <- cbind(lng=c(tmp$startLon[1], tmp$endLon),
                     lat=c(tmp$startLat[1], tmp$endLat))

        allroutes <- c(allroutes, list(tmp))
        nam <- c(nam, paste0(i, ur[r]))
    }
}
names(allroutes) <- nam
allroutes <- lapply(allroutes, as.data.frame)
