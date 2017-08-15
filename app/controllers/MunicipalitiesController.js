// MunicipalitiesController.js
// config & routing defined in js/olliApp.js

//-----------------------------------------------------------------------
olliApp.controller('MunicipalitiesController', ['$scope', 'munFactory', function ($scope, munFactory) {
    
    $scope.status;
    $scope.municipalities;
    $scope.municipalityDetails;
//    $scope.orders;

    ! function(){
        munFactory.getMunicipalities()
            .then(function (response) {
                $scope.municipalities = response.data.data.municipalities;
		$scope.api_mess = response.data.data.api_mess;
            }, function (error) {
                $scope.status = 'Unable to load municipalities data: ' + error.message;
            });
    }();

/*
    $scope.updateMunicipality = function (id) {
        var mun;
        for (var i = 0; i < $scope.municipalities.length; i++) {
            var currMun = $scope.municipalities[i];
            if (currMun.ID === id) {
                mun = currMun;
                break;
            }
        }

         munFactory.updateMunicipality(mun)
          .then(function (response) {
              $scope.status = 'Updated Municipality! Refreshing municipality list.';
          }, function (error) {
              $scope.status = 'Unable to update municipality: ' + error.message;
          });
    };

    $scope.insertMunicipality = function () {
        //Fake municipality data
        var mun = {
            ID: 10,
            FirstName: 'JoJo',
            LastName: 'Pikidily'
        };
        munFactory.insertMunicipality(mun)
            .then(function (response) {
                $scope.status = 'Inserted Municipality! Refreshing municipality list.';
                $scope.municipalities.push(mun);
            }, function(error) {
                $scope.status = 'Unable to insert municipality: ' + error.message;
            });
    };

    $scope.deleteMunicipality = function (id) {
        munFactory.deleteMunicipality(id)
        .then(function (response) {
            $scope.status = 'Deleted Municipality! Refreshing municipality list.';
            for (var i = 0; i < $scope.municipalities.length; i++) {
                var mun = $scope.municipalities[i];
                if (mun.ID === id) {
                    $scope.municipalities.splice(i, 1);
                    break;
                }
            }
            $scope.orders = null;
        }, function (error) {
            $scope.status = 'Unable to delete municipality: ' + error.message;
        });
    };
*/
/*
    $scope.getMunicipalityOrders = function (id) {
        munFactory.getOrders(id)
        .then(function (response) {
            $scope.status = 'Retrieved orders!';
            $scope.orders = response.data;
        }, function (error) {
            $scope.status = 'Error retrieving municipalities! ' + error.message;
        });
    };
*/

}]);
