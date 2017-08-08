// censusNormalizationController.js

//-----------------------------------------------------------------------
olliApp.controller('censusNormalizationController', ['$scope', '$routeParams', 'cenFactory', function ($scope, $routeParams, cenFactory) {
    $scope.munID = '';
    $scope.charID = '';
    $scope.status = 'Waiting.';
    // $scope.rawOutput = "No output.";
    $scope.output = '';

    $scope.getCensusValues = function(){
        $scope.status = "Calling for normalized values.";
        $scope.rawOutput = 'No output.';
        // $scope.output = 'No output';
        if(
            $scope.charId != ''
            || $scope.munID != ''
            ){

            // Create array for both charIDs and munIDs
            var charArr = ($scope.charID).split(' ');
            var munArr = ($scope.munID).split(' ');

            cenFactory.getValues(charArr, munArr)
                .then(function (response){
                    $scope.rawOutput = response.data.data.rawOutput;
                    $scope.status = "Response successful.";

                    var outputArr = {};
                    // var len = ($scope.rawOutput).length;
                    // var len = munArr.length;
                    // outputArr.text2 = 'test2';
                    // outputArr.fred = {};
                    // outputArr.fred.text3 = 'test3';
                    // var lengthInnerMun = ($scope.rawOutput[0][0][1]).length;
                    // outputArr.lengthInnerMun = lengthInnerMun;

                    for(var m_id_idx = 0; m_id_idx < munArr.length; m_id_idx++){
                        outputArr
                    }

                    // outputArr["text2"] = 'test2';
                    // outputArr.push({test2: "test2"});
                    // outputArr[0].munID = $scope.rawOutput[0][0];
                    // $scope.output = outputArr[0].munID;
                    // $scope.output = outputArr;
                    $scope.output = [{"x": "23"}, {"x": "34"}];

                    // var outputArr = [];
                    // var len = rawOutput.length;
                    // outputArr.text = "asdf";
                    // $scope.output = 'asdf';
                    // for(var m_id_idx = 0; m_id_idx < output.length; m_id_idx++){
                    //     output[0]
                    // }

                    

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