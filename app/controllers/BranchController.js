// BranchController.js

//-----------------------------------------------------------------------
olliApp.controller('BranchController', ['$scope', '$routeParams', 'branchFactory', function ($scope, $routeParams, branchFactory) {
    
    $scope.status;
    $scope.library;
    $scope.branch;
    $scope.hours;
    $scope.contacts;
    $scope.collections;
    $scope.circulations;
	
    ! function(){
		// grab branch ID off the route
		//var libID = ($routeParams.libID ? parseInt($routeParams.libID) : 0);
		var branchID = ($routeParams.branchID ? parseInt($routeParams.branchID) : 0);
		if (branchID > 0) {
			branchFactory.getBranch( branchID )
			.then(function (response) {
				$scope.library = response.data.data.library;
				$scope.branch = response.data.data.branch;
				$scope.hours = response.data.data.hours;
				$scope.contacts = response.data.data.contacts;
				$scope.collections = response.data.data.collections;
				$scope.circulations = response.data.data.circulations;
				
			}, function (error) {
						$scope.status = 'Unable to load library data: ' + error.message;
			});
		}
    }();
}]);
