## R and C++ code to calculate distance from street to point

In seeking to identify which points (eg pothole locations) are within
some distance of a given block (represented as some path), we want to
be able to calculate

 - distance between two points (x0,y0) and (x1,y1)
 - distance between a point (x0,y0) and a segment (x1,y1) to (x2,y2)
 - distance between a point and a path, which we'll take as the
   minimum of the distances of the point to each of the path segments

Load the code with

    Rcpp::sourceCpp("calc_distances.cpp")

The R functions it creates:

    calc_dist_pt2pt(pt1, pt2) # pt1 and pt2 are each matrices with 2 cols
    calc_dist_pt2seg(pt1, seg) # pt1 is vector of length 2; seg is matrix with 2 rows and 2 cols
