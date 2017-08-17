// PairAnalysisController.js

//-----------------------------------------------------------------------
olliApp.controller('PairAnalysisController', ['$scope', '$routeParams', 'pairAnalysisFactory', function ($scope, $routeParams, pairAnalysisFactory) {
    $scope.status = 'Waiting.';
    $scope.rawOutput = '';
    $scope.filtered;

    $scope.compute = function(){
        $scope.status = "Calling for all pairs.";
        $scope.rawOutput = 'No output.';
        pairAnalysisFactory.computeAllPairs()
            .then(function (response){
                $scope.rawOutput = response.data.data.rawOutput;
                $scope.filtered = $scope.rawOutput;
                $scope.status = "Successful response.";

                $scope.tableList = [];
                $scope.fieldList = [];
                var length = $scope.rawOutput[0].length;

                for(var pairIdx = 0; pairIdx < length; pairIdx++){
                    $scope.tableList.push($scope.rawOutput[0][pairIdx][0]);
                    $scope.fieldList.push($scope.rawOutput[0][pairIdx][1]);
                    $scope.fieldList.push($scope.rawOutput[0][pairIdx][3]);
                }

                $scope.tableList = $scope.tableList.unique();
                $scope.fieldList = $scope.fieldList.unique();
            }, function (error){
                $scope.status = "ERROR " + error.status;
            });
    }

    Array.prototype.contains = function(v) {
        for(var i = 0; i < this.length; i++)
            if(this[i] === v)  
                return true;
        return false;
    };

    Array.prototype.unique = function() {
        var arr = [];
        for(var i = 0; i < this.length; i++)
            if(this[i] != '' && !arr.contains(this[i]))
                arr.push(this[i]);
        return arr; 
    }
}]);