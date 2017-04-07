# Convert shapefile to GeoJSON:

ogr2ogr \
  -f GeoJSON \
  geojson/geoMunData.js.pre \
  shapefiles/muni_mb_gdf8_shp_eng/GeoBase_MUNI_MB_1_0_eng.shp

gawk 'BEGIN{print "var geoMunData =\n"}{print}END{print ";\n"}' geojson/geoMunData.js.pre > geojson/geoMunData.js

mv geojson/geoMunData.js ../app/geo/
rm geojson/geoMunData.js.pre

# NOTE:
# edit geoMunData.js to add:
#   var geoMunData =
# at the start, and
#   ;
# at the end.

# Then move it to app/geo/geoMunData.js

ogr2ogr \
  -f GeoJSON \
  geojson/geoProvBoundary.js.pre \
  shapefiles/manitoba_administrative/manitoba_administrative.shp

gawk 'BEGIN{print "var geoProvBoundary =\n"}{print}END{print ";\n"}' geojson/geoProvBoundary.js.pre > geojson/geoProvBoundary.js
mv geojson/geoProvBoundary.js ../app/geo/
rm geojson/geoProvBoundary.js.pre

ogr2ogr \
  -f GeoJSON \
  geojson/geoSimpleWater.js.pre \
  shapefiles/simple_lakes_and_water/simple_lakes_and_water.shp

gawk 'BEGIN{print "var geoSimpleWater =\n"}{print}END{print ";\n"}' geojson/geoSimpleWater.js.pre > geojson/geoSimpleWater.js
mv geojson/geoSimpleWater.js ../app/geo/
rm geojson/geoSimpleWater.js.pre

ogr2ogr \
  -f GeoJSON \
  geojson/geoRoads.js.pre \
  shapefiles/manitoba_highway/manitoba_highway.shp

gawk 'BEGIN{print "var geoRoads =\n"}{print}END{print ";\n"}' geojson/geoRoads.js.pre > geojson/geoRoads.js
mv geojson/geoRoads.js ../app/geo/
rm geojson/geoRoads.js.pre

