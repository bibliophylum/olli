// censusNormalizationController.js

//-----------------------------------------------------------------------
olliApp.controller('censusNormalizationController', ['$scope', '$routeParams', 'cenFactory', function ($scope, $routeParams, cenFactory) {
    $scope.munID = '';
    $scope.charID = '';
    $scope.status = 'Waiting.';
    $scope.munList = "Empty";
    $scope.needCharsList = true;
    $scope.charsList = [];
    $scope.needValidCharsList = true;
    $scope.validCharsList = [];
    $scope.rawOutput;

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

            if(charArr.length == 0 || munArr.length == 0)
                $scope.status = "Invalid parameters!"
            else{
                cenFactory.getValues(charArr, munArr)
                    .then(function (response){
                        $scope.rawOutput = response.data.data.rawOutput;
                        $scope.status = "Successful response.";
                    }, function (error){
                        // $scope.status = "ERROR " + error.status;
                        $scope.status = error.data.data.status;
                    });
            }
        }
        else{
            if($scope.charId == '' && $scope.munID == '')
                $scope.status = "Empty parameters!";
            else
                $scope.status = "Empty parameter!";
        }
        $scope.charID = '';
        $scope.munID = '';
    }

    $scope.getValidChars = function(){
        $scope.status = "Calling for valid chars list.";
        $scope.rawOutput = 'No output.';
        $scope.needValidCharsList = true;


        var munArr = ($scope.munID).split(' ');
        munArr = munArr.uniqueNumbers();        

        cenFactory.getValidChars(munArr, $scope.needCharsList)
            .then(function (response){
                $scope.charsList = response.data.data.charsList;
                $scope.validCharsList = response.data.data.validCharsList;
                $scope.status = "Successful response.";
            }, function (error){
                $scope.status = "ERROR " + error.status;
            });
        $scope.needCharsList = false;
        $scope.needValidCharsList = false;
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