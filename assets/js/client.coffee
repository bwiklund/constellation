app = angular.module 'constellation', []


app.factory 'Search', ($http,$q) ->
  # so we can not stomp on newer data. todo: cancel http calls
  lastSatisfiedRequestNum = requestCount = 0 

  search: (str) ->
    myRequestNum = requestCount++
    $http.get('/json',params:q:str).then (res) ->
      lastSatisfiedRequestNum = Math.max lastSatisfiedRequestNum, myRequestNum
      if myRequestNum <= lastSatisfiedRequestNum
        res.data
      else
        console.log 'cancelling', myRequestNum
        $q.reject('ooo')


app.controller 'MainCtrl', ($scope, $location, Search) ->
  throttledSearch = _.throttle (str) ->
    Search.search(str).then (results) ->
      $scope.results = results
  , 500

  $scope.$watch 'query', (str) ->
    throttledSearch(str) if str

    