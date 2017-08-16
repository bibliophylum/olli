// censusNormalizationController.js

//-----------------------------------------------------------------------
olliApp.controller('censusNormalizationController', ['$scope', '$routeParams', 'cenFactory', function ($scope, $routeParams, cenFactory) {
    $scope.munID = '';
    $scope.charID = '';
    $scope.status = 'Waiting.';
    $scope.munList = "Empty";

    ! function(){
        $scope.status = "Calling for valid municipalities.";
        $scope.rawOutput = 'No output.';

        cenFactory.getValidMuns()
            .then(function (response){
                $scope.munList = response.data.data.rawOutput;

            }, function (error){
                $scope.status = "ERROR " + error.status;
            });
        $scope.status = "Waiting."
    }();

    $scope.getCensusValues = function(){
        $scope.status = "Calling for normalized values.";
        $scope.rawOutput = 'No output.';
        if(
            $scope.charId != ''
            && $scope.munID != ''
            ){
            // Create array for both charIDs and munIDs, each only holding unique integers
            var charArr = ($scope.charID).split(' ');
            charArr = charArr.uniqueNumbers();

            var munArr = ($scope.munID).split(' ');
            munArr = munArr.uniqueNumbers();

            $scope.charID = '';
            $scope.munID = '';

            if(charArr.length == 0 || munArr.length == 0)
                $scope.status = "Invalid parameters!"
            else{
                cenFactory.getValues(charArr, munArr)
                    .then(function (response){
                        $scope.rawOutput = response.data.data.rawOutput;
                        $scope.status = "Successful response.";
                    }, function (error){
                        $scope.status = "ERROR " + error.status;
                    });
            }
        }
        else{
            if($scope.charId == '' && $scope.munID == '')
                $scope.status = "Empty parameters!";
            else
                $scope.status = "Empty parameter!";
        }
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