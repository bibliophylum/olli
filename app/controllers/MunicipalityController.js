// MunicipalityController.js
// config & routing defined in js/olliApp.js

//-----------------------------------------------------------------------
olliApp.controller('MunicipalityController', ['$scope', '$routeParams', 'munFactory', function ($scope, $routeParams, munFactory) {
    
    $scope.status;
    $scope.municipalityDetails;
    $scope.census_year;
    $scope.contributions;
    $scope.census;

    init();

    function init() {
	// grab municipality ID off the route
	var munID = ($routeParams.munID ? parseInt($routeParams.munID) : 0);
	if (munID > 0) {
            munFactory.getMunicipalityDetails( munID )
		.then(function (response) {
                    $scope.municipalityDetails = response.data.data.municipality;
		    $scope.api_mess = response.data.data.api_mess;
		    $scope.census_year = response.data.data.census_year;
		    $scope.contributions = response.data.data.contributions;
		    $scope.census = response.data.data.census;

		    // set visibility of each subset
		    angular.forEach( $scope.census, function(value, topic) {
			$scope.census.topic.visible = false;
			angular.forEach( $scope.census.topic, function(v2,ord) {
			    $scope.census.topic.ord.visible = false;
			});
		    });

		    // zoom the map to this municipality
		    

		}, function (error) {
                    $scope.status = 'Unable to load municipality data: ' + error.message;
		});
	}
	
    }

}]);
