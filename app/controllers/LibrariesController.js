// LibrariesController.js

//-----------------------------------------------------------------------
olliApp.factory('libFactory', ['$http', function($http) {

    var urlBase = '/api/libraries';
    var libFactory = {};

    libFactory.getLibraries = function () {
        return $http.get(urlBase);
    };

    libFactory.getLibrary = function (id) {
        return $http.get(urlBase + '/' + id);
    };

    libFactory.insertLibrary = function (mun) {
        return $http.post(urlBase, mun);
    };

    libFactory.updateLibrary = function (mun) {
        return $http.put(urlBase + '/' + mun.ID, mun)
    };

    libFactory.deleteLibrary = function (id) {
        return $http.delete(urlBase + '/' + id);
    };

/*    libFactory.getOrders = function (id) {
        return $http.get(urlBase + '/' + id + '/orders');
    };
*/
    return libFactory;
}]);

//-----------------------------------------------------------------------
olliApp.controller('LibrariesController', ['$scope', 'libFactory', function ($scope, libFactory) {
    
    $scope.status;
    $scope.libraries;
//    $scope.orders;

    ! function(){
        libFactory.getLibraries()
            .then(function (response) {
                $scope.libraries = response.data.data.libraries;
		$scope.api_mess = response.data.data.api_mess;
            }, function (error) {
                $scope.status = 'Unable to load libraries data: ' + error.message;
            });
    }();

    $scope.updateLibrary = function (id) {
        var mun;
        for (var i = 0; i < $scope.libraries.length; i++) {
            var currMun = $scope.libraries[i];
            if (currMun.ID === id) {
                mun = currMun;
                break;
            }
        }

         libFactory.updateLibrary(mun)
          .then(function (response) {
              $scope.status = 'Updated Library! Refreshing library list.';
          }, function (error) {
              $scope.status = 'Unable to update library: ' + error.message;
          });
    };

    $scope.insertLibrary = function () {
        //Fake library data
        var mun = {
            ID: 10,
            FirstName: 'JoJo',
            LastName: 'Pikidily'
        };
        libFactory.insertLibrary(mun)
            .then(function (response) {
                $scope.status = 'Inserted Library! Refreshing library list.';
                $scope.libraries.push(mun);
            }, function(error) {
                $scope.status = 'Unable to insert library: ' + error.message;
            });
    };

    $scope.deleteLibrary = function (id) {
        libFactory.deleteLibrary(id)
        .then(function (response) {
            $scope.status = 'Deleted Library! Refreshing library list.';
            for (var i = 0; i < $scope.libraries.length; i++) {
                var mun = $scope.libraries[i];
                if (mun.ID === id) {
                    $scope.libraries.splice(i, 1);
                    break;
                }
            }
            $scope.orders = null;
        }, function (error) {
            $scope.status = 'Unable to delete library: ' + error.message;
        });
    };
/*
    $scope.getLibraryOrders = function (id) {
        libFactory.getOrders(id)
        .then(function (response) {
            $scope.status = 'Retrieved orders!';
            $scope.orders = response.data;
        }, function (error) {
            $scope.status = 'Error retrieving libraries! ' + error.message;
        });
    };
*/
}]);
