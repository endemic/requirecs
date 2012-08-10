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
	'text!templates/options.html'
], ($, Backbone, env, Scene, DialogBox, template) ->
	class OptionsScene extends Scene
		events: ->
			# Determine whether touchscreen or desktop
			if env.mobile
				events =
					'touchstart .back': 'back' 
					'touchstart .reset': 'reset'
					'touchstart .feedback': 'feedback'

			else
				events =
					'click .back': 'back' 
					'click .reset': 'reset'
					'click .feedback': 'feedback'

		initialize: ->
			@elem = $(template)
			@render()

		back: (e) ->
			e.preventDefault()
			@trigger 'sfx:play', 'button'
			@trigger 'scene:change', 'title'

		feedback: (e) ->
			e.preventDefault()
			# window.location.href = "mailto:info@ganbarugames.com"
			# window.open("mailto:info@ganbarugames.com", "email")

		reset: (e) ->
			e.preventDefault()
			@trigger 'sfx:play', 'button'
			
			new DialogBox
				el: @elem
				title: 'Erase saved data?'
				buttons: [
					{ 
						text: 'Yes'
						callback: => 
							stats = 
								beginner: {}
								easy: {}
								medium: {}
								hard: {}

							complete = 
								beginner: 0
								easy: 0
								medium: 0
								hard: 0

							localStorage.setObject 'stats', stats
							localStorage.setObject 'complete', complete
					},
					{
						text: 'No'
					}
				]