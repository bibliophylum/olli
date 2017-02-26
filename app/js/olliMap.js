// olliMap.js
// setting up the leaflet map

$( document ).ready(function() {
    // NOTE: leaflet uses [ lat, long ], but GeoJSON uses [ long, lat ].
    // Copy the point from the geojson file, but switch them here:
    var mymap = L.map('mapid').setView([ 50.3021654, -98.0323209 ], 7);  // coords of Portage la Prairie, from munis.json

    L.geoJSON(geoMunData).addTo(mymap);
    
});

