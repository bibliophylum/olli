// olliApp.js
// Routing/configuration


var olliApp = angular.module('olliModule',['ngRoute']);

//-----------------------------------------------------------------------
olliApp.config(function ($routeProvider,$locationProvider) {
    /* change ?v= to force cache update */
    $routeProvider
	.when('/municipalities', {
	    controller: 'MunicipalitiesController',
	    templateUrl: 'partials/municipalities.html'
	})
	.when('/municipalities/:munID', {
	    controller: 'MunicipalityController',
	    templateUrl: 'partials/municipality-details.html?v=4'
	})
	.when('/libraries', {
	    controller: 'LibrariesController',
	    templateUrl: 'partials/libraries.html'
	})
	.when('/libraries/:libID', {
	    controller: 'LibraryController',
	    templateUrl: 'partials/library.html'
	})
        .otherwise({ redirectTo: '/municipalities' });

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

    munFactory.getMunicipalityDetails = function (id) {
        return $http.get(urlBase + '/' + id);
    };

/*    
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
*/
/*    munFactory.getOrders = function (id) {
        return $http.get(urlBase + '/' + id + '/orders');
    };
*/
    return munFactory;
}]);

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
/*
    libFactory.insertLibrary = function (mun) {
        return $http.post(urlBase, mun);
    };

    libFactory.updateLibrary = function (mun) {
        return $http.put(urlBase + '/' + mun.ID, mun)
    };

    libFactory.deleteLibrary = function (id) {
        return $http.delete(urlBase + '/' + id);
    };

    libFactory.getOrders = function (id) {
        return $http.get(urlBase + '/' + id + '/orders');
    };
*/
    return libFactory;
}]);

