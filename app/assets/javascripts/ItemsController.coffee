controllers = angular.module('controllers')
controllers.controller("ItemsController", [ '$scope', '$routeParams', '$location', '$resource',
  ($scope,$routeParams,$location,$resource)->
    $scope.search = (keywords)->  $location.path("/").search('keywords',keywords)
    Item = $resource('/items/:itemId', { itemId: "@id", format: 'json' })

    if $routeParams.keywords
      Item.query(keywords: $routeParams.keywords, (results)-> $scope.items = results)
    else
      $scope.items = []
])