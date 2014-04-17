'use strict'

angular
  .module('Grid', [])
  .service 'GenerateUniqueId',
    class GenerateUniqueId
      next: ->
        d = new Date().getTime()
        'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c) ->
          r = (d + Math.random() * 16) % 16 | 0
          d = Math.floor(d / 16)
          if (c == 'x')
            r
          else
            (r & 0x7 | 0x8).toString(16)

  .factory('TileModel', ['GenerateUniqueId', (GenerateUniqueId) ->
    class @TileModel
      constructor: (pos, val) ->
        @x = pos.x
        @y = pos.y
        @id = GenerateUniqueId.next()
        @value = val || 2
        @merged = null

      updatePosition: (newPos) ->
        @x = newPos.x
        @y = newPos.y

      reset: ->
        @merged = null
  ])

  .provider 'GridService',
    class @GridService
      $get: ['TileModel', (TileModel) ->
        class Get
          grid: []
          tiles: []
          size: 4
          startTileNumber: 2

          vectors:
            'left': {x: -1, y: 0}
            'right': {x: 1, y: 0}
            'up': {x: 0, y: -1}
            'down': {x: 0, y: 1}

          newTile: (pos, value) ->
            new TileModel pos, value

          prepareTiles: ->
            @forEach (x, y, tile) ->
              if tile
                tile.reset()

          traversalDirections: (key) ->
            vector = @vectors[key]
            positions = {x: [0...@size], y: [0...@size]}
            if vector.x > 0
              positions.x = positions.x.reverse()
            if vector.y > 0
              positions.y = positions.y.reverse()
            positions

          calculateNextPosition: (cell, key) ->
            vector = @vectors[key]
            previous = null

            loop
              previous = cell
              cell =
                x: previous.x + vector.x
                y: previous.y + vector.y
              break unless (@withinGrid(cell) and @cellAvailable(cell))

            return {
              newPosition: previous
              next: @getCellAt cell
            }

          cellAvailable: (cell) ->
            if @withinGrid cell
              !@getCellAt cell
            else
              null

          samePositions: (a, b) ->
            a.x == b.x and a.y == b.y

          moveTile: (tile, newPosition) ->
            oldPos = x: tile.x, y: tile.y
            @removeTile tile

            tile.updatePosition newPosition
            @insertTile tile

          buildStartingPosition: ->
            @randomlyInsertNewTile() for i in [0...@startTileNumber]

          randomlyInsertNewTile: ->
            cell = @randomAvailableCell()
            @insertTile(@newTile(cell, 2))

          randomAvailableCell: ->
            cells = @availableCells()
            if cells.length > 0
              cells[Math.floor(Math.random() * cells.length)]

          availableCells: ->
            cells = []
            @forEach (x, y) =>
              if not @getCellAt({x: x, y: y})
                cells.push({x: x, y: y})
            cells

          buildEmptyGameBoard: ->
            @grid = (null for i in [1..(@size * @size)])
            @forEach (x, y) =>
              @setCellAt({x: x, y: y}, null)

          forEach: (cb) ->
            totalSize = @size * @size
            for i in [0...totalSize]
              pos = @_positionToCoordinates(i)
              cb(pos.x, pos.y, @tiles[i])

          insertTile: (tile) ->
            @setCellAt({x: tile.x, y: tile.y}, tile)

          removeTile: (tile) ->
            @setCellAt({x: tile.x, y: tile.y}, null)

          setCellAt: (pos, tile) ->
            if @withinGrid(pos)
              xPos = @_coordinatesToPosition(pos)
              @tiles[xPos] = tile

          getCellAt: (pos) ->
            if @withinGrid(pos)
              xPos = @_coordinatesToPosition(pos)
              @tiles[xPos]
            else
              null

          withinGrid: (pos) ->
            pos.x >= 0 and pos.x < @size and pos.y >=0 and pos.y < @size

          anyCellsAvailable: ->
            @availableCells().length > 0

          tileMatchesAvailable: ->
            totalSize = @size * @size
            for tile in @tiles
              if tile
                for vectorName, vector of @vectors
                  cell =
                    x: tile.x + vector.x
                    y: tile.y + vector.y
                  other = @getCellAt cell
                  if other and other.value == tile.value
                    return true
            false

          _positionToCoordinates: (i) ->
            x: i % @size
            y: (i - i % @size) / @size

          _coordinatesToPosition: (pos) ->
            pos.x + pos.y * @size

        new Get()
      ]
