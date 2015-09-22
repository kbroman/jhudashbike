# code to convert streets.txt file to a list with street names and coordinates

# grab text in 2nd span, for getting street and block number
grab_2nd_span <-
    function(txt)
{
    result <- xml(txt) %>%
        html_nodes(xpath="//span//text()") %>%
            capture.output()
    result[5] %>%
        gsub("^\\s+", "", .) %>%
            gsub("\\s+$", "", .)
}

# grab coordinates
grab_coord <-
    function(txt)
{
    result <- xml(txt) %>%
        html_nodes(xpath="//coordinates//text()") %>%
            capture.output()
    latlong <- as.numeric(strsplit(result[2], ",|\\s")[[1]])
    if(length(latlong)==2) {
        names(latlong) <- c("lat", "long")
    }
    else {
        latlong <- matrix(latlong, ncol=2, byrow=TRUE)
        colnames(latlong) <- c("lat", "long")
    }
    latlong

}

convert_streets <-
    function(vec, quiet=FALSE)
{
    library(rvest)
    start <- grep("<MultiGeometry", vec)
    end <-  grep("</MultiGeometry", vec)

    result <- vector("list", length(start))
    for(i in seq(along=start)) {
        if(!quiet && i == round(i,-2)) message(i)

        fn <- vec[start[i]-2]
        if(grepl("FULLNAME", fn))
           fn <- grab_2nd_span(fn)
        else fn <- ""

        bl <- vec[start[i]-1]
        if(grepl("BLOCK_NUM", bl))
           bl <- as.numeric(grab_2nd_span(bl))
        else bl <- NA

        result[[i]] <- list(name     = fn,
                            number   = bl,
                            position = grab_coord(vec[start[i]+1]),
                            path1    = grab_coord(vec[start[i]+2]))
        if(start[i]+3 < end[i])
            result[[i]]$path2 <- grab_coord(vec[start[i]+3])
    }
    result
}

# do the work
streets <- convert_streets( readLines("streets.txt") )

# save to file
saveRDS(streets, "streets.rds")
