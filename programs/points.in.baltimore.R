library(sp)


points.in.baltimore <- funciton(longitude.vector, latitude.vector){
bdy <- matrix(c(-76.7113,39.372, -76.5297,39.372, -76.5299,39.2096, -76.5497,39.1972,
                -76.5837,39.2081, -76.6116,39.2344, -76.7112,39.2778, -76.7113,39.372), ncol=2, byrow=TRUE)
bdy <- as.data.frame(bdy)
colnames(bdy) <- c("lon", "lat")
return(point.in.polygon(longitude.vector, latitude.vector, pol.x = bdy[,1], pol.y = bdy[,2], mode.checked=FALSE) > 0 )	
}