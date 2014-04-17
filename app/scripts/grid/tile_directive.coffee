'use strict'

angular
  .module('Grid')
  .directive 'tile', ->
    restrict: 'A'
    require: 'ngModel'
    scope:
      ngModel: '='
    templateUrl: 'scripts/grid/tile.html'
