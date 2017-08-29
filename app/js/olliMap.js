// olliMap.js
// setting up the leaflet map

$( document ).ready(function() {
    // NOTE: leaflet uses [ lat, long ], but GeoJSON uses [ long, lat ].
    // Copy the point from the geojson file, but switch them here:
    var map = L.map('mapid', {
		minZoom: 5,
		maxZoom: 14,
		center: [ 50.3021654, -98.0323209 ], // coords of Portage la Prairie, from munis.json
		zoom: 6
	});

	var response;
	var jsonResponse;
	// var currentYear = '2011';

	! function(){
		var url = '/api/munMapping';
		var xmlHttp = new XMLHttpRequest();
		xmlHttp.onreadystatechange = function() { 
			if (xmlHttp.readyState == 4 && xmlHttp.status == 200){
				response = xmlHttp.responseText;
				jsonResponse = JSON.parse(response)["data"]["rawOutput"];
				// alert(jsonResponse);
			}
		}
		xmlHttp.open("GET", url, true); // true for asynchronous 
		xmlHttp.send(null);
	}();

	geojson = L.geoJson(geoMunData, {
		style: function (feature) {
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
		}
	}).addTo(map);

	geojson = L.geoJson(geoSimpleWater, {
		style: function (feature) {
			return {
			'weight': 1,
			'color': 'navy',
			'fillColor': 'blue'
			}
		}
	}).addTo(map);

	// control that shows state info on hover
	var info = L.control();

	info.onAdd = function (map) {
		this._div = L.DomUtil.create('div', 'info');
		this._div.style.padding = '6px 8px';
		this._div.style.background = 'rgba(255,255,255,0.85)';
		this._div.style.boxShadow = '0 0 15px rgba(0,0,0,0.2)';
		this._div.style.borderRadius = '5px';
		this.update();
		return this._div;
	};

	info.update = function (props) {
		var containsIdx = -1;
		if(props && jsonResponse != null)
			containsIdx = arrContains(jsonResponse, props);
		this._div.innerHTML =
			(props ?
			'<h4><b>' + props.COMMONAME1 + '</b></h4>'
			+ (containsIdx != -1 ? '<h5><b>Found, index of ' + containsIdx + 
			'<br>Mun ID: ' + jsonResponse[containsIdx][0] +
			'<br>Designation: ' + jsonResponse[containsIdx][2] + '</b></h5>':
			'<h5><b>Not found<b></h5>'): 
			'<h4><b>Hover over a municipality</b><h4>');
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

		if (!L.Browser.ie && !L.Browser.opera && !L.Browser.edge)
			layer.bringToFront();
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

		if (!L.Browser.ie && !L.Browser.opera && !L.Browser.edge)
			layer.bringToFront();
		info.update();
	}

	function zoomToFeature(e) {
		map.fitBounds(e.target.getBounds(), {padding: [75, 75]});
	}

	function onEachFeature(feature, layer) {
		layer.on({
			mouseover: highlightFeature,
			mouseout: resetHighlight,
			click: munAction
		});
	}

	// Takes different actions depending on the current partial and validity of chosen municipality (whether it is linked to the db)
	function munAction(e){
		var layer = e.target;
		var munResponse;
		var containsIdx = arrContains(jsonResponse, layer.feature.properties);
		var split = window.location.href.split('/');

		if(split[split.length - 1] == 'pairAnalysis'
		|| split[split.length - 1] == 'libraries'
		|| split[split.length - 2] == 'libraries')
				zoomToFeature(e);

		else if(containsIdx != -1){
			if(split[split.length - 1] == 'municipalities'
			|| split[split.length - 2] == 'municipalities'){
				zoomToFeature(e);
				var scope = angular.element(document.getElementById('leftpane')).scope();
				scope.$apply(angular.element(scope.location.path('municipalities/' + jsonResponse[containsIdx][0])));
			}

			else if(split[split.length - 1] == 'censusNormalization'
				 || split[split.length - 1] == 'munGrouping'){
				if(document.getElementById('munTextbox').value == '')
					document.getElementById('munTextbox').value += jsonResponse[containsIdx][0];
				else
					document.getElementById('munTextbox').value += ' ' + jsonResponse[containsIdx][0];

				angular.element(document.getElementById('munTextbox')).trigger('input');

				if(split[split.length - 1] == 'censusNormalization'){
					angular.element(document.getElementById('mainDiv')).scope().getValidChars();
					window.parent.updateCharTable();
				}
			}
		}
	}

	// If arr is defined and contains the correct values, returns index of matching values within arr, else returns -1.
    function arrContains(arr, props) {
        for(var i = 0; i < arr.length; i++)
            if(arr[i] != null && parseInt(arr[i][1]) == parseInt(props.LOCALID) && arr[i][2] == props.DESIGNATN)// && currentYear == arr[i][3])
				return i;
        return -1;
    };

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