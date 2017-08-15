// munGroupingController.js

//-----------------------------------------------------------------------
olliApp.controller('munGroupingController', ['$scope', '$routeParams', 'munGroupingFactory', function ($scope, $routeParams, munGroupingFactory) {
    $scope.munID = '';
    $scope.status = 'Waiting.';
    $scope.rawOutput = '';
    $scope.munList = "Empty";

    ! function(){
        $scope.status = "Calling for valid municipalities.";
        $scope.rawOutput = 'No output.';

        munGroupingFactory.getValidMuns()
            .then(function (response){
                $scope.munList = response.data.data.rawOutput;

            }, function (error){
                $scope.status = "ERROR " + error.status;
            });
        $scope.status = "Waiting."
    }();

    $scope.group = function(){
        $scope.status = "Calling for grouping.";
        $scope.rawOutput = 'No output.';
        if($scope.munID != ''){
            // Create array for munIDs, only holds unique integers
            var munArr = ($scope.munID).split(' ');
            munArr = munArr.uniqueNumbers();

            if(munArr.length == 0)
                $scope.status = "Invalid parameter!"
            else{
                munGroupingFactory.getGrouping(munArr)
                    .then(function (response){
                        $scope.rawOutput = response.data.data.rawOutput;
                        $scope.status = "Successful response.";
                    }, function (error){
                        $scope.status = "ERROR " + error.status;
                    });
            }
        }
        else
            $scope.status = "Empty parameter!";
        $scope.munID = '';
    }

    Array.prototype.contains = function(v) {
        for(var i = 0; i < this.length; i++)
            if(this[i] === v)
                return true;
        return false;
    };

    Array.prototype.uniqueNumbers = function() {
        var arr = [];
        for(var i = 0; i < this.length; i++)
            if(this[i] != '' && !arr.contains(this[i]) && !isNaN(parseInt(this[i])) && isFinite(this[i]))
                arr.push(this[i]);
        return arr; 
    }
}]);