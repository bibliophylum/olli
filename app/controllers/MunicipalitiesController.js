// MunicipalitiesController.js

var olliApp = angular.module('olliModule',['ngRoute']);

//-----------------------------------------------------------------------
olliApp.config(function ($routeProvider,$locationProvider) {
    $routeProvider
	.when('/', {
	    controller: 'MunicipalitiesController',
	    templateUrl: 'partials/municipalities.html'
	})
        .when("/view2", {
  	    controller: 'SimpleController', // could be different controller
	    templateUrl: 'partials/view2.html'
        })
        .otherwise({ redirectTo: '/' });

    /* you can pass parameters to a route like this:
       .when("/customer/:customerID", { ... });
    */
    
    // use the HTML5 History API
    $locationProvider.html5Mode(true);
});	     

//-----------------------------------------------------------------------
olliApp.factory('munFactory', ['$http', function($http) {

    var urlBase = '/api/municipalities';
    var munFactory = {};

    munFactory.getMunicipalities = function () {
        return $http.get(urlBase);
    };

    munFactory.getMunicipality = function (id) {
        return $http.get(urlBase + '/' + id);
    };

    munFactory.insertMunicipality = function (mun) {
        return $http.post(urlBase, mun);
    };

    munFactory.updateMunicipality = function (mun) {
        return $http.put(urlBase + '/' + mun.ID, mun)
    };

    munFactory.deleteMunicipality = function (id) {
        return $http.delete(urlBase + '/' + id);
    };

/*    munFactory.getOrders = function (id) {
        return $http.get(urlBase + '/' + id + '/orders');
    };
*/
    return munFactory;
}]);

//-----------------------------------------------------------------------
olliApp.controller('MunicipalitiesController', ['$scope', 'munFactory', function ($scope, munFactory) {
    
    $scope.status;
    $scope.municipalities;
//    $scope.orders;

    getMunicipalities();

    function getMunicipalities() {
        munFactory.getMunicipalities()
            .then(function (response) {
                $scope.municipalities = response.data.data.municipalities;
		$scope.api_mess = response.data.data.api_mess;
            }, function (error) {
                $scope.status = 'Unable to load municipalities data: ' + error.message;
            });
    }

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
