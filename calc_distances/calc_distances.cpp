// calculate distance from street to point
#include <Rcpp.h>
using namespace Rcpp;
#define TOL 1e-12

// calculate great circle distance
double calc_spheredist_pt2pt(NumericVector pt1, NumericVector pt2)
{
    const double earth_rad = 6371; // km (3959 mi)
    // (from https://en.wikipedia.org/wiki/Earth_radius)

    // latitude and longitude in radians
    double lng1 = pt1[0]*PI/180.0;
    double lat1 = pt1[1]*PI/180.0;
    double lng2 = pt2[0]*PI/180.0;
    double lat2 = pt2[1]*PI/180.0;

    // (distance formula from https://en.wikipedia.org/wiki/Great-circle_distance)
    return earth_rad * acos(sin(lat1)*sin(lat2) +
                            cos(lat1)*cos(lat2)*cos(fabs(lng1-lng2)));

}


// calc scaling factor for latitude and longitude to kilometers
NumericVector calc_scales()
{
    // find scales
    const double balto_lng_max = -76.5297;
    const double balto_lng_min = -76.7113;
    const double balto_lat_max = 39.1972;
    const double balto_lat_min = 39.3720;

    NumericVector point1(2), point2(2), result(2);

    // lng scale
    point1[0] = balto_lng_min;
    point2[0] = balto_lng_max;
    point1[1] = point2[1] = (balto_lat_min + balto_lat_max)/2.0;
    result[0] = calc_spheredist_pt2pt(point1, point2)/(balto_lng_max - balto_lng_min);

    // lat scale
    point1[1] = balto_lat_min;
    point2[1] = balto_lat_max;
    point1[0] = point2[0] = (balto_lng_min + balto_lng_max)/2.0;
    result[1] = calc_spheredist_pt2pt(point1, point2)/(balto_lat_max - balto_lat_min);

    return result;
}


// scale latitude and longitude to kilometers
// [[Rcpp::export(".rescale_points_vec")]]
NumericVector rescale_points_vec(NumericVector pt)
{
    NumericVector scale = calc_scales();
    NumericVector balto_min(2);
    balto_min[0] = -76.7113; // long
    balto_min[1] = 39.3720; // lat

    NumericVector result(2);

    for(int i=0; i<2; i++)
        result[i] = pt[i]*scale[i] - balto_min[i]*scale[i];

    return result;
}

// scale latitude and longitude to kilometers
// [[Rcpp::export(".rescale_points_matrix")]]
NumericMatrix rescale_points_matrix(NumericMatrix pt)
{
    NumericVector scale = calc_scales();
    NumericVector balto_min(2);
    balto_min[0] = -76.7113; // long
    balto_min[1] = 39.3720; // lat

    const int nrows = pt.rows();
    NumericMatrix result(nrows, 2);

    for(int j=0; j<2; j++)
        for(int i=0; i<nrows; i++)
            result(i,j) = pt(i,j)*scale[j] - balto_min[j]*scale[j];

    return result;
}


/*** R
# R function for rescaling points (as vec or matrix)
rescale_points <-
function(pt)
{
    if(!is.matrix(pt) && !is.data.frame(pt)) {
        stopifnot(length(pt)==2)
        return(.rescale_points_vec(pt))
    }

    stopifnot(ncol(pt)==2)
    .rescale_points_matrix(as.matrix(pt))
}
***/


// calculate distance between two points
//  (longitude and latitude, in degrees or km)
double calc_dist_pt2pt_one(NumericVector pt1, NumericVector pt2, bool scale_to_km=false)
{
    double result=0.0;

    NumericVector pt1a(2), pt2a(2);
    if(scale_to_km) {
        pt1a = rescale_points_vec(pt1);
        pt2a = rescale_points_vec(pt2);
    }
    else {
        for(int i=0; i<2; i++) {
            pt1a[i] = pt1[i];
            pt2a[i] = pt2[i];
        }
    }

    for(int i=0; i<2; i++) {
        double val = (pt1a[i]-pt2a[i]);
        result += (val*val);
    }

    return sqrt(result);
}

// calculate distance between two lists of points
// pt1 and pt2 are each matrices with two columns
// (longitude and latitude, in degrees or km)
// [[Rcpp::export(".calc_dist_pt2pt")]]
NumericMatrix calc_dist_pt2pt(NumericMatrix pt1, NumericMatrix pt2, bool scale_to_km=true)
{
    int nr1 = pt1.rows(), nr2 = pt2.rows();
    int nc1 = pt1.cols(), nc2 = pt2.cols();
    if(nc1 != 2) throw std::invalid_argument("pt1 should have two columns");
    if(nc2 != 2) throw std::invalid_argument("pt2 should have two columns");

    NumericMatrix result(nr1,nr2);
    NumericMatrix pt1a(nr1,2), pt2a(nr2,2);

    if(scale_to_km) {
        pt1a = rescale_points_matrix(pt1);
        pt2a = rescale_points_matrix(pt2);
    }
    else {
        for(int j=0; j<2; j++) {
            for(int i=0; i<nr1; i++)
                pt1a(i,j) = pt1(i,j);
            for(int i=0; i<nr2; i++)
                pt2a(i,j) = pt2(i,j);
        }
    }

    for(int i=0; i<nr1; i++) {
        for(int j=0; j<nr2; j++) {
            result(i,j) = calc_dist_pt2pt_one(pt1a(i,_), pt2a(j,_));
        }
    }

    return result;
}

/*** R
calc_dist_pt2pt <-
function(pt1, pt2, scale_to_km=TRUE)
{
    # convert vector to 1-row matrix
    if(!is.matrix(pt1) && !is.data.frame(pt1))
        pt1 <- rbind(pt1)
    if(!is.matrix(pt2) && !is.data.frame(pt2))
        pt2 <- rbind(pt2)

    stopifnot(ncol(pt1) == 2)
    stopifnot(ncol(pt2) == 2)

    .calc_dist_pt2pt(as.matrix(pt1), as.matrix(pt2), scale_to_km)
}
*/



// distance from point to line
// (from http://mathworld.wolfram.com/Point-LineDistance2-Dimensional.html)
double calc_dist_pt2line(NumericVector pt, NumericMatrix seg, bool scale_to_km=false)
{
    NumericVector pta(2);
    NumericMatrix sega(2,2);
    if(scale_to_km) {
        pta = rescale_points_vec(pt);
        sega = rescale_points_matrix(seg);
    }
    else {
        for(int j=0; j<2; j++) {
            pta[j] = pt[j];
            for(int i=0; i<2; i++)
                sega(i,j) = seg(i,j);
        }
    }

    double x0=pta[0], y0=pta[1];
    double x1=sega(0,0), y1=sega(0,1);
    double x2=sega(1,0), y2=sega(1,1);

    return fabs((x2-x1)*(y1-y0) - (x1-x0)*(y2-y1))/
        sqrt((x2-x1)*(x2-x1) - (y2-y1)*(y2-y1));
}


// project point onto a line
// (from http://www.vcskicks.com/code-snippet/point-projection.php)
// points should already be in km
NumericVector project_pt2line(NumericVector pt, NumericMatrix seg, bool scale_to_km=false)
{
    NumericVector pta(2);
    NumericMatrix sega(2,2);
    if(scale_to_km) {
        pta = rescale_points_vec(pt);
        sega = rescale_points_matrix(seg);
    }
    else {
        for(int j=0; j<2; j++) {
            pta[j] = pt[j];
            for(int i=0; i<2; i++)
                sega(i,j) = seg(i,j);
        }
    }
    double x0=pta[0], y0=pta[1];
    double x1=sega(0,0), y1=sega(0,1);
    double x2=sega(1,0), y2=sega(1,1);

    NumericVector result(2);

    if(fabs(x1-x2) < TOL) { // same x
        result[0] = x1;
        result[1] = pt[1];
    }
    else if(fabs(y1-y2) < TOL) { // same y
        result[0] = pt[0];
        result[1] = y1;
    }
    else { // general case
        double m = (y2-y1)/(x2-x1);
        result[0] = (x0/m + y0 - y1 + m*x1)/(m+1.0/m);
        result[1] = m*(result[0] - x1) + y1;
    }

    return result;
}

// calculate minimum distance between point x
// and a segment y -> z
// pt and seg should be (longitude, latitude)
//
// [[Rcpp::export(".calc_dist_pt2seg")]]
double calc_dist_pt2seg(NumericVector pt, NumericMatrix seg, bool scale_to_km=true)
{
    NumericVector pta(2);
    NumericMatrix sega(2,2);
    if(scale_to_km) {
        pta = rescale_points_vec(pt);
        sega = rescale_points_matrix(seg);
    }
    else {
        for(int j=0; j<2; j++) {
            pta[j] = pt[j];
            for(int i=0; i<2; i++)
                sega(i,j) = seg(i,j);
        }
    }

    // project point onto line
    NumericVector projection = project_pt2line(pta, sega);

    // distance from projection to endpoints of the segment
    double proj_to_start = calc_dist_pt2pt_one(projection, sega(0,_));
    double proj_to_end = calc_dist_pt2pt_one(projection, sega(1,_));

    // length of the segment
    double seg_length = calc_dist_pt2pt_one(sega(0,_), sega(1,_));

    if(proj_to_start >= seg_length ||
       proj_to_end >= seg_length) { // projection outside segment
        double pt_to_start = calc_dist_pt2pt_one(pta, sega(0,_));
        double pt_to_end = calc_dist_pt2pt_one(pta, sega(1,_));
        if(pt_to_start <= pt_to_end)
            return pt_to_start;
        else
            return pt_to_end;
    }
    else { // projection is on the line segment
        // return distance from point to line
        return calc_dist_pt2line(pta, sega);
    }
}

/*** R
calc_dist_pt2seg <-
function(pt, seg, scale_to_km=TRUE)
{
    stopifnot(length(pt)==2)
    stopifnot(ncol(seg)==2)

    .calc_dist_pt2seg(pt, as.matrix(seg), scale_to_km)
}
*/
