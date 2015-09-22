// calculate distance from street to point
#include <Rcpp.h>
using namespace Rcpp;
#define TOL 1e-12

// calculate distance between two points
double calc_dist_pt2pt_one(NumericVector pt1, NumericVector pt2)
{
    double result=0.0;

    for(int i=0; i<2; i++) {
        double val = (pt1[i]-pt2[i]);
        result += (val*val);
    }

    return sqrt(result);
}

// calculate distance between two lists of points
//
// pt1 and pt2 are each matrices with two columns
// [[Rcpp::export]]
NumericMatrix calc_dist_pt2pt(NumericMatrix pt1, NumericMatrix pt2)
{
    int nr1 = pt1.rows(), nr2 = pt2.rows();
    int nc1 = pt1.cols(), nc2 = pt2.cols();
    if(nc1 != 2) throw std::invalid_argument("pt1 should have two columns");
    if(nc2 != 2) throw std::invalid_argument("pt2 should have two columns");

    NumericMatrix result(nr1,nr2);

    for(int i=0; i<nr1; i++) {
        for(int j=0; j<nr2; j++) {
            result(i,j) = calc_dist_pt2pt_one(pt1(i,_), pt2(j,_));
        }
    }

    return result;
}

// distance from point to line
// (from http://mathworld.wolfram.com/Point-LineDistance2-Dimensional.html)
double calc_dist_pt2line(NumericVector pt, NumericMatrix seg)
{
    double x0=pt[0], y0=pt[1];
    double x1=seg(0,0), y1=seg(0,1);
    double x2=seg(1,0), y2=seg(1,1);

    return fabs((x2-x1)*(y1-y0) - (x1-x0)*(y2-y1))/
        sqrt((x2-x1)*(x2-x1) - (y2-y1)*(y2-y1));
}


// project point onto a line
// (from http://www.vcskicks.com/code-snippet/point-projection.php)
NumericVector project_pt2line(NumericVector pt, NumericMatrix seg)
{
    double x0=pt[0], y0=pt[1];
    double x1=seg(0,0), y1=seg(0,1);
    double x2=seg(1,0), y2=seg(1,1);

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
//
// [[Rcpp::export]]
double calc_dist_pt2seg(NumericVector pt, NumericMatrix seg)
{
    // project point onto line
    NumericVector projection = project_pt2line(pt, seg);
    Rcout << "projection: " << projection[0] << " " << projection[1] << std::endl;

    // distance from projection to endpoints of the segment
    double proj_to_start = calc_dist_pt2pt_one(projection, seg(0,_));
    double proj_to_end = calc_dist_pt2pt_one(projection, seg(1,_));
    Rcout << "proj_to_start: " << proj_to_start << std::endl;
    Rcout << "proj_to_end: " << proj_to_end << std::endl;

    // length of the segment
    double seg_length = calc_dist_pt2pt_one(seg(0,_), seg(1,_));
    Rcout << "seg_length: " << seg_length << std::endl;

    if(proj_to_start >= seg_length ||
       proj_to_end >= seg_length) { // projection outside segment
        Rcout << "off end: " << std::endl;
        double pt_to_start = calc_dist_pt2pt_one(pt, seg(0,_));
        Rcout << "pt_to_start: " << pt_to_start << std::endl;
        double pt_to_end = calc_dist_pt2pt_one(pt, seg(1,_));
        Rcout << "pt_to_end: " << pt_to_end << std::endl;
        if(pt_to_start <= pt_to_end)
            return pt_to_start;
        else
            return pt_to_end;
    }
    else { // projection is on the line segment
        // return distance from point to line
        Rcout << "on line: " << std::endl;
        return calc_dist_pt2line(pt, seg);
    }
}
