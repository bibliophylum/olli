// SimpleController.js

/* controller doesn't know anything about the view
// $scope is the glue between controller and view
// At this point, $scope contains "name" from ng model defined within the div
// You can access it by using $scope.name
*/

/*
           Module
             |
           Config
             |
           Routes
             /\
            /  \
    _______/    \_______
   /                    \
 View <--> $scope <--> Controller
  |                       |
 Directives            *Factory


*/

//var demoApp = angular.module('olliModule',['ngRoute', 'ngAnimate']);
var demoApp = angular.module('olliModule',['ngRoute']);

demoApp.config(function ($routeProvider,$locationProvider) {
    $routeProvider
	.when('/', {
	    controller: 'SimpleController',
	    templateUrl: 'partials/view1.html'
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

//demoApp.factory('simpleFactory', function($http) {
demoApp.factory('simpleFactory', function() {
    // we can use $http to do an ajax call to get data...
    // for this demo, just mock up some data
    var customers = [
        {custName:'John Smith',city:'Brandon'},
        {custName:'Jane Smith',city:'Winnipeg'},
        {custName:'John Doe',city:'Winkler'}
    ];

    var factory = {};  // empty object
    factory.getCustomers = function() {
	// ajax call would go here, return a promise (?)
	return customers;
    };
    factory.putCustomer = function(customer) {
	// you can have multiple factories....
    };

    return factory;
});

demoApp.controller('SimpleController', function($scope, simpleFactory) {
    /* $scope object dynamically added through dependency injection
       Now add property "customers" to $scope object
    */
    $scope.customers = [];

    // You could call simpleFactory.getCustomers() directly.  But this way,
    // if we have any initialization stuff that needs to happen with the
    // factory, we can collect it all into one place (the local function, init())
    init();

    function init() {
	// ... any other factory initialization stuff ...
	$scope.customers = simpleFactory.getCustomers();
    }
    
    $scope.addCustomer = function() {
	$scope.customers.push(
	    {
		custName: $scope.newCustomer.name,
		city: $scope.newCustomer.city
	    });
    }
});

