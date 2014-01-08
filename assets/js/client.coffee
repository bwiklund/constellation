app = angular.module 'constellation', []


app.factory 'Search', ($http) ->
  search: (str) -> $http.get('/json',params:q:str).then (res) -> res.data


app.controller 'MainCtrl', ($scope, $location, Search) ->
  $scope.$watch 'query', (str) ->
    if str
      Search.search(str).then (results) ->
        $scope.results = results