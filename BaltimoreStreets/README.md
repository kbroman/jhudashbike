## Center lines of Baltimore streets

<https://data.baltimorecity.gov/Geographic/Street-Centerlines/tau7-6emy>

click on "Export" and "KML"

Ultimately, I used `grep` to pull out the relevant lines from the
KML file, and then parsed them within R. Here's the `grep` line:

    grep "FULLNAME\|BLOCK_NUM\|coordinates\|MultiGeometry" "Street Centerlines.kml" > streets.txt

The R code is in `convert_streets.R`.

Three main oddities:

 - There are a 1681 streets with no name

 - There are a 9975 streets with block number = `-9`.

 - There are four streets with two paths

The converted data is in `streets.rds`. It's a list with 48160
components, each component being a list with

 - `name` (the street name; `""` if missing)
 - `number` (the block number; I think `-9` is missing)
 - `position` (a latitude, longitude position)
 - `path1` (a path, as a matrix with two columns (latitude and
   longitude))
 - `path2` (in four cases, there's a second path for the street)

Read the data into R with

    streets <- readRDS("streets.rds")

---

Here are the other things I tried:


### Reading KML into R

I tried reading the file with `rgdal::readOGR`, but I couldn't figure
out the appropriate "layer".

### Converting to GeoJSON

Following <http://apprentice.craic.com/tutorials/28>, I converted the
file to GeoJSON with the Geospatial Data Abstraction Library (GDAL),
installed with Homebrew on Mac OSX with:

    brew install gdal

The actual conversion was with

    ogr2ogr -f geojson "Street Centerlines.geojson" "Street Centerlines.kml"

To read the GeoJSON file into R, I tried using

    streets <- rgdal::readOGR("Street Centerlines.geojson", "OGRGeoJSON")

but I got an error `Incompatible geometry: 7`, plus a bunch of
warnings, `eType not chosen`

So I tried to just use JSON, as follows:

    streets <- jsonlite::fromJSON(readLines("Street Centerlines.geojson"))

but the result was just a mess.
