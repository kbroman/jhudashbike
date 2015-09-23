# functions related to counting incidents near each block in Baltimore City

# load other functions to use
Rcpp::sourceCpp("../calc_distances/calc_distances.cpp")
source("../programs/points.in.baltimore.R")

# load street data
streets <- readRDS("../BaltimoreStreets/streets.rds")

# find points that are close to a path
# (in 2 steps: distance to center, than distance to path for close-ish points
find_close_pts2path <-
    function(pts, path_obj, max_d=0.05)
{
    L <- calc_pathlength(path_obj$path1)

    dpos <- calc_dist_pt2pt(pts, path_obj$pos)

    if(!is.null(path_obj$path2)) { # has two paths; brute force it
        L <- L + calc_pathlength(path_obj$path2)
        wh <- which(dpos <= L + max_d)
        dpath <- cbind(calc_dist_pts2path(pts[wh,,drop=FALSE], path_obj$path1),
                       calc_dist_pts2path(pts[wh,,drop=FALSE], path_obj$path2))
        dpath <- apply(dpath, 1, min)

    }
    else {
        wh <- which(dpos <= L + max_d)
        dpath <- calc_dist_pts2path(pts[wh,,drop=FALSE], path_obj$path1)
    }
    wwh <- which(dpath <= max_d)
    return( cbind(d=dpath[wwh], index=wh[wwh]) )

}

find_length <-
    function(path_obj)
{
    L <- calc_pathlength(path_obj$path1)

    if(!is.null(path_obj$path2)) { # has two paths; brute force it
        L <- L + calc_pathlength(path_obj$path2)
    }

    L
}
