// censusNormalizationController.js

//-----------------------------------------------------------------------
olliApp.controller('censusNormalizationController', ['$scope', '$routeParams', 'cenFactory', function ($scope, $routeParams, cenFactory) {
    $scope.munID = '';
    $scope.charID = '';
    $scope.status = 'Waiting.';
    $scope.output = "No output.";

    $scope.getCensusValues = function(){
        $scope.status = "Calling for normalized values.";
        $scope.output = 'No output.';
        if(
            $scope.charId != ''
            || $scope.munID != ''
            ){

            // Create array for both charIDs and munIDs
            var charArr = ($scope.charID).split(' ');
            var munArr = ($scope.munID).split(' ');

            cenFactory.getValues(charArr, munArr)
                .then(function (response){
                    $scope.output = response.data.data.output;
                    $scope.status = "Response successful.";
                }, function (error){
                    $scope.status = "ERROR " + error.status;
                });
        }
        else{
            $scope.status = "INVALID PARAMETERS!";
        }
        $scope.charID = '';
        $scope.munID = '';
    }
}]);