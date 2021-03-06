{CompositeDisposable, Disposable} = require 'atom'

MinimapGitDiffBinding = null

class MinimapGitDiff

  config:
    useGutterDecoration:
      type: 'boolean'
      default: false
      description: 'When enabled the git diffs will be displayed as thin vertical lines on the left side of the minimap.'

  pluginActive: false
  constructor: ->
    @subscriptions = new CompositeDisposable

  isActive: -> @pluginActive

  activate: ->
    @bindings = new WeakMap

  consumeMinimapServiceV1: (@minimap) ->
    @minimap.registerPlugin 'git-diff', this

  deactivate: ->
    @destroyBindings()
    @minimap = null

  activatePlugin: ->
    return if @pluginActive

    try
      @createBindings()
      @pluginActive = true

      @subscriptions.add @minimap.onDidActivate @createBindings
      @subscriptions.add @minimap.onDidDeactivate @destroyBindings
    catch e
      console.log e

  deactivatePlugin: ->
    return unless @pluginActive

    @pluginActive = false
    @subscriptions.dispose()
    @destroyBindings()

  createBindings: =>
    MinimapGitDiffBinding ||= require './minimap-git-diff-binding'

    @subscriptions.add @minimap.observeMinimaps (o) =>
      minimap = o.view ? o
      editor = minimap.getTextEditor()

      return unless editor?

      binding = new MinimapGitDiffBinding minimap
      @bindings.set(minimap, binding)

  destroyBindings: =>
    return unless @minimap? and @minimap.editorsMinimaps?
    @minimap.editorsMinimaps.forEach (minimap) =>
      @bindings.get(minimap)?.destroy()
      @bindings.delete(minimap)

module.exports = new MinimapGitDiff
