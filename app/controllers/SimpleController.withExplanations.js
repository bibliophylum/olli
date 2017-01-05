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

// if the module depends on other modules (e.g. to fetch data), those
// other modules will be listed in the array here:
//                                           |
//                                          \|/
var demoApp = angular.module('testappModule',[])
    .controller('SimpleController', function($scope) {
        /* $scope object dynamically added through dependency injection
           Now add property "customers" to $scope object
        */
        $scope.customers = [
          {custName:'John Smith',city:'Brandon'},
          {custName:'Jane Smith',city:'Winnipeg'},
          {custName:'John Doe',city:'Winkler'}
        ];
    });

// could also do it without chaining:
/*  ng-app points to this -----
                               \
var demoApp = angular.module('testappModule',[]);

demoApp.controller('SimpleController', function($scope) {
        $scope.customers = [
          {custName:'John Smith',city:'Brandon'},
          {custName:'Jane Smith',city:'Winnipeg'},
          {custName:'John Doe',city:'Winkler'}
        ];
    });
*/


/* if we had another module we wanted SimpleController to have access to:
var demoApp = angular.module('testappModule',['helperModule']);

...where helperModule is another module defined in (possibly) another .js file
(which must be included along with SimpleController.js)
*/

// see https://weblogs.asp.net/dwahlin/angularjs-routing-changes
