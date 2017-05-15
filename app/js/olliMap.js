// olliMap.js
// setting up the leaflet map

$( document ).ready(function() {
    // NOTE: leaflet uses [ lat, long ], but GeoJSON uses [ long, lat ].
    // Copy the point from the geojson file, but switch them here:
    var mymap = L.map('mapid').setView([ 50.3021654, -98.0323209 ], 6);  // coords of Portage la Prairie, from munis.json

    L.geoJSON(geoMunData, {
	style: function (feature) { // Style option
	    return {
		'weight': 1,
		'color': 'black',
		'fillColor': 'yellow'
	    }
	}
    }).addTo(mymap);
    
    L.geoJSON(geoProvBoundary, {
	style: function (feature) {
	    return {
		'weight': 1,
		'color': 'black'
	    }
	}
    }).addTo(mymap);
    
    L.geoJSON(geoSimpleWater, {
	style: function (feature) {
	    return {
		'weight': 1,
		'color': 'navy',
		'fillColor': 'blue'
	    }
	}
    }).addTo(mymap);
//    L.geoJSON(geoRoads).addTo(mymap);
    
});

/*
From http://stackoverflow.com/questions/28339414/leaflet-change-map-color:

$.getJSON('world.geo.json', function (geojson) { // load file
    L.geoJson(geojson, { // initialize layer with data
        style: function (feature) { // Style option
            return {
                'weight': 1,
                'color': 'black',
                'fillColor': 'yellow'
            }
        }
    }).addTo(map); // Add layer to map
});

*/
