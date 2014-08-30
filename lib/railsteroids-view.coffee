{View} = require 'atom'

module.exports =
class RailsteroidsView extends View
  @content: ->
    @div class: 'railsteroids overlay from-top', =>
      @div "The Railsteroids package is Alive! It's ALIVE!", class: "message"

  initialize: (serializeState) ->
    atom.workspaceView.command "railsteroids:toggle", => @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    console.log "RailsteroidsView was toggled!"
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)
