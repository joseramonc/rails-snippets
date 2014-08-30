RailsteroidsView = require './railsteroids-view'

module.exports =
  railsteroidsView: null

  activate: (state) ->
    @railsteroidsView = new RailsteroidsView(state.railsteroidsViewState)

  deactivate: ->
    @railsteroidsView.destroy()

  serialize: ->
    railsteroidsViewState: @railsteroidsView.serialize()
