// NavController.js

//-----------------------------------------------------------------------
olliApp.controller('NavController', ['$scope', '$location', function ($scope, $location) {

    $scope.navClass = function (page) {
	var currentRoute = $location.path().substring(1) || 'home';
	return page === currentRoute ? 'active' : '';
    };
    
    $scope.loadHome = function () {
        $location.url('/home');
    };
    
    $scope.loadMunicipalities = function () {
        $location.url('/municipalities');
    };
    
    $scope.loadLibraries = function () {
        $location.url('/libraries');
    };

    $scope.loadCensusEntry = function () {
        $location.url('/censusNormalization');
    };

    $scope.loadMunGrouping = function () {
        $location.url('/munGrouping');
    };

    $scope.loadPairAnalysis = function () {
        $location.url('/pairAnalysis');
    };
    
}]);
