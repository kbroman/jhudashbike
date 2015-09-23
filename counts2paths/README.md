## Counts to paths

The code and results in this directory concern the characterizations
of all of the blocks in `BaltimoreStreets/` based on counts of nearby
points of things, such as 311 reports and traffic accidents.

Each street block has a discrete path, plus a center. I first
calculate the distance from each point to each path center. Then for a
subset of the points with distance < some value, I calculate the
minimal distance from the point to the path. I then find all of the
distances that are < some other value.

I then can count the number of points < any distance (perhaps 0.01),
divided by the length of the path.

I'll make a histogram of those, choose some cutoffs, and make graphs
of the blocks with the worst values.

`counts2paths.R` contains various higher-level functions that I'll
use. The directory `calc_distances` has the C++ code that calculates
the distances.
