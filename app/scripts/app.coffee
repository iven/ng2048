'use strict'

angular
  .module('twentyfourtyeightApp', ['Game', 'Keyboard', 'ngAnimate'])
  .controller 'GameController',
    class @GameController
      @$inject: ['GameManager', 'KeyboardService']

      constructor: (@game, @KeyboardService) ->
        @newGame()

      newGame: ->
        @KeyboardService.init()
        @game.newGame()
        @startGame()

      startGame: ->
        @KeyboardService.on (key) =>
          @game.move(key)
