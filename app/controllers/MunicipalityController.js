// MunicipalityController.js
// config & routing defined in js/olliApp.js

//-----------------------------------------------------------------------
olliApp.controller('MunicipalityController', ['$scope', '$routeParams', 'munFactory', function ($scope, $routeParams, munFactory) {
    
    $scope.status;
    $scope.municipalityDetails;

    init();

    function init() {
	// grab municipality ID off the route
	var munID = ($routeParams.munID ? parseInt($routeParams.munID) : 0);
	if (munID > 0) {
            munFactory.getMunicipalityDetails( munID )
		.then(function (response) {
                    $scope.municipalityDetails = response.data.data.municipality;
		    $scope.api_mess = response.data.data.api_mess;
		}, function (error) {
                    $scope.status = 'Unable to load municipalities data: ' + error.message;
		});
	}
	
    }

}]);
