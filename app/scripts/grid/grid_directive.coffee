'use strict'

angular
  .module('Grid')
  .directive 'grid', ->
    restrict: 'A'
    require: 'ngModel'
    scope:
      ngModel: '='
    templateUrl: 'scripts/grid/grid.html'
