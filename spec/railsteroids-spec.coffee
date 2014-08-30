{WorkspaceView} = require 'atom'
Railsteroids = require '../lib/railsteroids'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "Railsteroids", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('railsteroids')

  describe "when the railsteroids:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.railsteroids')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'railsteroids:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.railsteroids')).toExist()
        atom.workspaceView.trigger 'railsteroids:toggle'
        expect(atom.workspaceView.find('.railsteroids')).not.toExist()
