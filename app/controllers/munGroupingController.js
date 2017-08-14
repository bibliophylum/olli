// munGroupingController.js

//-----------------------------------------------------------------------
olliApp.controller('munGroupingController', ['$scope', '$routeParams', 'munGroupingFactory', function ($scope, $routeParams, munGroupingFactory) {
    $scope.munID = '';
    $scope.status = 'Waiting.';
    $scope.rawOutput = '';
    $scope.munList = "Empty";

    init();

    function init(){
        $scope.status = "Calling for valid municipalities.";
        $scope.rawOutput = 'No output.';

        munGroupingFactory.getValidMuns()
            .then(function (response){
                // $scope.status = "Valid response!";
                $scope.munList = response.data.data.rawOutput;

            }, function (error){
                $scope.status = "ERROR " + error.status;
            });
        $scope.status = "Waiting."
    }

    $scope.group = function(){
        $scope.status = "Calling for grouping.";
        $scope.rawOutput = 'No output.';
        if($scope.munID != ''){

            var munArr = ($scope.munID).split(' ');
            munGroupingFactory.getGrouping(munArr)
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
        $scope.munID = '';
    }
}]);