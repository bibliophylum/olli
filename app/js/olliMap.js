// olliMap.js
// setting up the leaflet map

$( document ).ready(function() {
    // NOTE: leaflet uses [ lat, long ], but GeoJSON uses [ long, lat ].
    // Copy the point from the geojson file, but switch them here:
    var mymap = L.map('mapid').setView([ 50.3021654, -98.0323209 ], 6);  // coords of Portage la Prairie, from munis.json

    L.geoJSON(geoMunData).addTo(mymap);
    L.geoJSON(geoProvBoundary).addTo(mymap);
    L.geoJSON(geoSimpleWater).addTo(mymap);
//    L.geoJSON(geoRoads).addTo(mymap);
    
});

