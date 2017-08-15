// censusNormalizationController.js

//-----------------------------------------------------------------------
olliApp.controller('censusNormalizationController', ['$scope', '$routeParams', 'cenFactory', function ($scope, $routeParams, cenFactory) {
    $scope.munID = '';
    $scope.charID = '';
    $scope.status = 'Waiting.';

    $scope.getCensusValues = function(){
        $scope.status = "Calling for normalized values.";
        $scope.rawOutput = 'No output.';
        if(
            $scope.charId != ''
            && $scope.munID != ''
            ){

            // Create array for both charIDs and munIDs
            var charArr = ($scope.charID).split(' ');
            var munArr = ($scope.munID).split(' ');

            $scope.charID = '';
            $scope.munID = '';

            cenFactory.getValues(charArr, munArr)
                .then(function (response){
                    $scope.rawOutput = response.data.data.rawOutput;
                    $scope.status = "Successful response.";
                }, function (error){
                    $scope.status = "ERROR " + error.status;
                });
        }
        else{
            $scope.status = "INVALID PARAMETERS!";
        }
    }
}]);