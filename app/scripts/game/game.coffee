'use strict'

angular
  .module('Game', ['Grid', 'ngCookies'])
  .service 'GameManager',
    class @GameManager
      $inject: ['$q', '$cookieStore', 'GridService']
      currentScore: 0
      highScore: 0
      winningValue: 2048
      gameOver: false
      wine: false

      constructor: (@$q, @$cookieStore, @GridService) ->
        @grid = @GridService.grid
        @tiles = @GridService.tiles

      # Create a new Game
      newGame: ->
        @GridService.buildEmptyGameBoard()
        @GridService.buildStartingPosition()
        @reinit()

      reinit: ->
        @gameOver = false
        @win = false
        @currentScore = 0
        @highScore = @getHighScore()

      # Handle the move action
      move: (key) ->
        f = () =>
          return false if @win

          hasWon = false
          hasMoved = false
          positions = @GridService.traversalDirections key
          @GridService.prepareTiles()
          for x in positions.x
            for y in positions.y
              originalPosition = {x: x, y: y}
              tile = @GridService.getCellAt originalPosition
              if tile
                cell = @GridService.calculateNextPosition tile, key
                next = cell.next
                if next and (next.value == tile.value) and !next.merged
                  newValue = tile.value * 2
                  mergedTile = @GridService.newTile tile, newValue
                  mergedTile.merged = [tile, cell.next]
                  @GridService.insertTile mergedTile
                  @GridService.removeTile tile
                  @GridService.moveTile mergedTile, next
                  @updateScore(@currentScore + newValue)
                  if mergedTile.value >= @winningValue
                    hasWon = true
                  hasMoved = true
                else
                  @GridService.moveTile(tile, cell.newPosition)

                if !@GridService.samePositions(originalPosition, cell.newPosition)
                  hasMoved = true

          if hasWon and !self.win
            @win = true
          if hasMoved
            @GridService.randomlyInsertNewTile()
            if @win or !@movesAvailable()
              @gameOver = true

        @$q.when(f())

      getHighScore: ->
        parseInt(@$cookieStore.get('highScore')) || 0

      # Update the score
      updateScore: (newScore) ->
        @currentScore = newScore
        if @currentScore > @getHighScore()
          @highScore = newScore
          @$cookieStore.put 'highScore', newScore

      # Are there moves left?
      movesAvailable: ->
        @GridService.anyCellsAvailable() || @GridService.tileMatchesAvailable()
