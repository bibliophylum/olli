// LibraryController.js

//-----------------------------------------------------------------------
olliApp.controller('LibraryController', ['$scope', '$routeParams', 'libFactory', function ($scope, $routeParams, libFactory) {
    
    $scope.status;
    $scope.library;
    $scope.contributors;
    $scope.branches;
    $scope.hours;
    $scope.contacts;
    $scope.financial;
    $scope.collections;
    $scope.circulations;

    ! function(){
		// grab library ID off the route
		var libID = ($routeParams.libID ? parseInt($routeParams.libID) : 0);
		if (libID > 0) {
			libFactory.getLibrary( libID )
			.then(function (response) {
				$scope.library = response.data.data.library;
				$scope.contributors = response.data.data.contributors;
				$scope.branches = response.data.data.branches;
				$scope.hours = response.data.data.hours;
				$scope.contacts = response.data.data.contacts;
				$scope.financial = response.data.data.financial;
				$scope.collections = response.data.data.collections;
				$scope.circulations = response.data.data.circulations;
				
			}, function (error) {
						$scope.status = 'Unable to load library data: ' + error.message;
			});
		}
	}();
}]);
