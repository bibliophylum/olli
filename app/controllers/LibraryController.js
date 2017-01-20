// LibraryController.js

//-----------------------------------------------------------------------
olliApp.controller('LibraryController', ['$scope', '$routeParams', 'libFactory', function ($scope, $routeParams, libFactory) {
    
    $scope.status;
    $scope.library;
    $scope.contributors;

    init();

    function init() {
	// grab library ID off the route
	var libID = ($routeParams.libID ? parseInt($routeParams.libID) : 0);
	if (libID > 0) {
	    libFactory.getLibrary( libID )
		.then(function (response) {
		    $scope.library = response.data.data.library;
		    $scope.contributors = response.data.data.contributors;
		    
		}, function (error) {
                    $scope.status = 'Unable to load library data: ' + error.message;
		});
	}
    }

}]);
