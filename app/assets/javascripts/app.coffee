doozerdisplay = angular.module('doozerdisplay',[
  'templates',
  'ngRoute',
  'controllers',
])

doozerdisplay.config([ '$routeProvider',
  ($routeProvider)->
    $routeProvider
      .when('/',
        templateUrl: "display.html"
        controller: 'ItemsController'
      )
])

items = [
  {
    id: 1
    name: 'Baked Potato w/ Cheese'
  },
  {
    id: 2
    name: 'Garlic Mashed Potatoes',
  },
  {
    id: 3
    name: 'Potatoes Au Gratin',
  },
  {
    id: 4
    name: 'Baked Brussel Sprouts',
  },
]

controllers = angular.module('controllers',[])
controllers.controller("ItemsController", [ '$scope', '$routeParams', '$location',
  ($scope,$routeParams,$location)->
    $scope.search = (keywords)->  $location.path("/").search('keywords',keywords)

    if $routeParams.keywords
      keywords = $routeParams.keywords.toLowerCase()
      $scope.items = items.filter (item)-> item.name.toLowerCase().indexOf(keywords) != -1
    else
      $scope.items = []
])