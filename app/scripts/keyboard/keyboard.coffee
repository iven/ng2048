'use strict'

angular
  .module('Keyboard', [])
  .service 'KeyboardService',
    class @KeyboardService
      @$inject: ['$document']

      keyboardMap:
        37: 'left'
        38: 'up'
        39: 'right'
        40: 'down'

      keyEventHandlers: []

      constructor: (@$document) ->

      init: ->
        @$document.bind 'keydown', (event) =>
          key = @keyboardMap[event.which]
          if key
            event.preventDefault()
            @_handleKeyEvent key, event

      on: (cb) ->
        @keyEventHandlers.push(cb)

      _handleKeyEvent: (key, event) ->
        if @keyEventHandlers
          event.preventDefault()
          cb(key, event) for cb in @keyEventHandlers

