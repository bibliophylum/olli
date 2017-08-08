// munGroupingController.js

//-----------------------------------------------------------------------
olliApp.controller('munGroupingController', ['$scope', '$routeParams', 'munGroupingFactory', function ($scope, $routeParams, munGroupingFactory) {
    $scope.munID = '';
    $scope.status = 'Waiting.';
    // $scope.output = '';
    $scope.rawOutput = '';

    $scope.group = function(){
        $scope.status = "Calling for grouping.";
        $scope.rawOutput = 'No output.';
        // $scope.output = 'No output';
        if($scope.munID != ''){

            var munArr = ($scope.munID).split(' ');
            munGroupingFactory.getGrouping(munArr)
                .then(function (response){
                    $scope.rawOutput = response.data.data.rawOutput;
                    $scope.status = "Response successful.";
                }, function (error){
                    $scope.status = "ERROR " + error.status;$scope.rawOutput = response;
                });
        }
        else{
            $scope.status = "INVALID PARAMETERS!";
        }
        $scope.munID = '';
    }
}]);