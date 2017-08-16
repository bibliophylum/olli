// PairAnalysisController.js

//-----------------------------------------------------------------------
olliApp.controller('PairAnalysisController', ['$scope', '$routeParams', 'pairAnalysisFactory', function ($scope, $routeParams, pairAnalysisFactory) {
    $scope.status = 'Waiting.';
    $scope.rawOutput = '';

    $scope.compute = function(){
        $scope.status = "Calling for all pairs.";
        $scope.rawOutput = 'No output.';
        pairAnalysisFactory.computeAllPairs()
            .then(function (response){
                $scope.rawOutput = response.data.data.rawOutput;
                $scope.status = "Successful response.";
            }, function (error){
                $scope.status = "ERROR " + error.status;
            });
    }
}]);