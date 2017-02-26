# Convert shapefile to GeoJSON:

ogr2ogr \
  -f GeoJSON \
  geojson/geoMunData.js \
  shapefiles/muni_mb_gdf8_shp_eng/GeoBase_MUNI_MB_1_0_eng.shp

# NOTE:
# edit geoMunData.js to add:
#   var geoMunData =
# at the start, and
#   ;
# at the end.

# Then move it to app/geo/geoMunData.js
