###
AboutScene
	- Shows credits and lets user reset data
###
define [
	'jquery'
	'backbone'
	'cs!utilities/env'
	'cs!views/common/scene'
	'cs!views/common/dialog-box'
	'text!templates/about.html'
], ($, Backbone, env, Scene, DialogBox, template) ->
	class AboutScene extends Scene
		events: ->
			# Determine whether touchscreen or desktop
			if env.mobile
				events =
					'touchstart .back': 'back' 
			else
				events =
					'click .back': 'back' 

		initialize: ->
			@elem = $(template)
			@render()

		back: (e) ->
			e.preventDefault()
			@trigger 'sfx:play', 'button'
			@trigger 'scene:change', 'title'