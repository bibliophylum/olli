// olliApp.js
// Routing/configuration


var olliApp = angular.module('olliModule',['ngRoute']);

//-----------------------------------------------------------------------
olliApp.config(function ($routeProvider,$locationProvider) {
    $routeProvider
	.when('/municipalities', {
	    controller: 'MunicipalitiesController',
	    templateUrl: 'partials/municipalities.html'
	})
	.when('/municipalities/:id', {
	    controller: 'MunicipalitiesController',
	    templateUrl: 'partials/municipality-details.html'
	})
/*	.when('/municipality-details', {
	    controller: 'MunicipalitiesController',
	    templateUrl: 'partials/municipality-details.html'
	})
*/	.when('/libraries', {
	    controller: 'LibrariesController',
	    templateUrl: 'partials/libraries.html'
	})
        .otherwise({ redirectTo: '/municipalities' });

    /* you can pass parameters to a route like this:
       .when("/customer/:customerID", { ... });
    */
    
    // use the HTML5 History API
    $locationProvider.html5Mode(true);
});	     

