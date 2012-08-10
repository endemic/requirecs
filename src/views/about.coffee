###
AboutScene
	- Shows credits
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
					'touchstart .showDialog': 'showDialog'
			else
				events =
					'click .back': 'back' 
					'click .showDialog': 'showDialog'

		initialize: ->
			@elem = $(template)
			@render()

		back: (e) ->
			e.preventDefault()
			@trigger 'sfx:play', 'button'
			@trigger 'scene:change', 'title'

		showDialog: (e) ->
			e.preventDefault()

			new DialogBox
				el: @elem
				title: 'This is a dialog box with customizable buttons.'
				buttons: [
					{ 
						text: 'Yes'
						callback: => 
							console.log "Execute whatever you want as a callback."
					},
					{
						text: 'No'
						# This button just dismisses the dialog box
					}
				]