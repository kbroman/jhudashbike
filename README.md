## Bicycle safety in Baltimore

**Mission:  Characterize and map bicycle safety in Baltimore**

Website: <http://kbroman.org/jhudashbike>

### Geocoding

- ggmap package (function geocode), <https://github.com/dkahle/ggmap>

  the default `source="dst"` seems to be down for some people; if it
  doesn't work, try `ggmap::geocode("Baltimore, MD", source="google")`

- pelias, <https://github.com/pelias/pelias>

## Maps

- leaflet <http://rstudio.github.io/leaflet/>

## Data sources

- NHTSA - FARS website, (possibly) to get accident data from Baltimore
  <http://www-fars.nhtsa.dot.gov//QueryTool/QuerySection/SelectYear.aspx>

- Bikelanes
  <https://data.baltimorecity.gov/Transportation/Bike-Lanes/xzfj-gyms>

- Vehicle Collsions (investigated by state):
  <https://data.maryland.gov/Public-Safety/2012-Vehicle-Collisions-Investigated-by-State-Poli/pdvh-tf2u>

- Maybe we can email these people to get the incident reports that they have?
  <https://www.bikemaryland.org/resources/incident-report/>

- Bike info
  <http://www.pedbikeinfo.org/data/factsheet_crash.cfm>
