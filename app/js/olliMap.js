// olliMap.js
// setting up the leaflet map

$( document ).ready(function() {
    // NOTE: leaflet uses [ lat, long ], but GeoJSON uses [ long, lat ].
    // Copy the point from the geojson file, but switch them here:
    var map = L.map('mapid').setView([ 50.3021654, -98.0323209 ], 6);  // coords of Portage la Prairie, from munis.json

	geojson = L.geoJson(geoMunData, {
		style: function (feature) { // Style option
			return {
			'weight': 1,
			'color': 'black',
			'fillColor': 'yellow'
			}
		},
		onEachFeature: onEachFeature
	}).addTo(map);

	geojson = L.geoJson(geoProvBoundary, {
		style: function (feature) {
			return {
			'weight': 1,
			'color': 'black'
			}
		}//,
		// onEachFeature: onEachFeature
	}).addTo(map);

	geojson = L.geoJson(geoSimpleWater, {
		style: function (feature) {
			return {
			'weight': 1,
			'color': 'navy',
			'fillColor': 'blue'
			}
		}//,
		// onEachFeature: onEachFeature
	}).addTo(map);

	// control that shows state info on hover
	var info = L.control();

	info.onAdd = function (map) {
		this._div = L.DomUtil.create('div', 'info');
		this.update();
		return this._div;
	};

	info.update = function (props) {
		this._div.innerHTML = (props ?
			'<h4><b>' + props.COMMONAME1 + '</b></h4>' : '<h4><b>Hover over a municipality</b><h4>');
		this._div.style.color = 'red';
			// '<h4>US Population Density</h4>' +  (props ?
			// '<br>' + props.COMMONAME1 + '</b><br />'// + props.density + ' people / mi<sup>2</sup>'
			// : 'Hover over a municipality');
	};
	info.addTo(map);

	function highlightFeature(e) {
		var layer = e.target;

		layer.setStyle({
			weight: 5,
			// color: '#666',
			color: 'blue',
			dashArray: ''//,
			// fillOpacity: 0.7
		});

		if (!L.Browser.ie && !L.Browser.opera && !L.Browser.edge) {
			layer.bringToFront();
		}
		info.update(layer.feature.properties);
	}

	var geojson;

	function resetHighlight(e) {
		// geojson.resetStyle(e.target);
		var layer = e.target;

		layer.setStyle({
			'weight': 1,
			'color': 'black'//,
			// 'fillColor': 'yellow'
		})

		if (!L.Browser.ie && !L.Browser.opera && !L.Browser.edge) {
			layer.bringToFront();
		}
		info.update();
	}

	function zoomToFeature(e) {
		map.fitBounds(e.target.getBounds());
	}

	function onEachFeature(feature, layer) {
		layer.on({
			mouseover: highlightFeature,
			mouseout: resetHighlight,
			click: zoomToFeature
		});
	}

	// map.attributionControl.addAttribution('Population data &copy; <a href="http://census.gov/">US Census Bureau</a>');

	// var legend = L.control({position: 'bottomright'});
	// legend.onAdd = function (map) {
		
	// 	var div = L.DomUtil.create('div', 'info legend'),
	// 		grades = [0, 10, 20, 50, 100, 200, 500, 1000],
	// 		labels = [],
	// 		from, to;

	// 	for (var i = 0; i < grades.length; i++) {
	// 		from = grades[i];
	// 		to = grades[i + 1];

	// 		labels.push(
	// 			'<i style="background:' + getColor(from + 1) + '"></i> ' +
	// 			from + (to ? '&ndash;' + to : '+'));
	// 	}

	// 	div.innerHTML = labels.join('<br>');
	// 	return div;
	// };

	// legend.addTo(map);
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

// Choropleth Tutorial: http://leafletjs.com/examples/choropleth/example.html