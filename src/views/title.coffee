define [
	'jquery'
	'backbone'
	'cs!utilities/env'
	'cs!views/common/scene'
	'text!templates/title.html'
], ($, Backbone, env, Scene, template) ->
	class TitleScene extends Scene
		events: ->
			# Determine whether touchscreen or desktop
			if env.mobile
				events =
					'touchstart .about': 'about'
			else
				events =
					'click .about': 'about'

		initialize: ->
			@elem = $(template)
			@render()

		about: (e) ->
			e.preventDefault()
			@trigger 'sfx:play', 'button'
			@trigger 'scene:change', 'about'