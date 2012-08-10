###
pass args object like this
{
	title: "string"
	message: "string"
	buttons: [
		{
			text: 'OK'
			callback: ->
				dostuf()
		}
	]
}
###
define [
	'jquery'
	'backbone'
	'cs!utilities/env'
], ($, Backbone, env) ->
	class DialogBox extends Backbone.View
		animationTime: 300
		doCallback: true

		events: ->
			# Determine whether touchscreen or desktop
			if env.mobile
				events =
					'touchstart button': 'onAction'
					'orientationchange': 'orientationChange'
			else
				events =
					'click button': 'onAction'
					'orientationchange': 'orientationChange'

		initialize: ->
			if @options.animationTime? then @animationTime = @options.animationTime

			# Create HTML contents here
			html = ''

			if @options.title then html += "<h3>#{@options.title}</h3>"

			if @options.message then html += "<p>#{@options.message}</p>"

			for button in @options.buttons
				html += '<button data-action="' + button.text.toLowerCase() + '">' + button.text + '</button>'

			template = """<div class="dialog-box">#{html}</div>"""

			@overlay = $('<div class="overlay"></div>')

			@elem = $(template)
			@render()

		render: ->
			@$el.append @elem
			@elem.after @overlay

			# Dynamically position dialog box
			@elem.css
				left: (@$el.width() - @elem.width()) / 2
				top: -@elem.height()

			transition = if env.desktop then 'top' else 'translateY'
			animation = {}
			animation[transition] = if env.desktop then ((@$el.height() - @elem.height()) / 2) + 'px' else ((@$el.height() + @elem.height()) / 2) + 'px'
			animation.opacity = 1

			# animate box & overlay into place
			@elem.animate animation, @animationTime, 'swing'

			@overlay.animate { opacity: 0.7 }, @animationTime

		# Determine which button was clicked, call the appropriate callback, then close the dialog box view
		onAction: (e) ->
			e.preventDefault()

			# Allow button to only be clicked once
			if !@doCallback then return
			@doCallback = false

			buttonAction = $(e.target).attr 'data-action'

			# Search through the buttons array, looking for the callback associated w/ the clicked button
			for button in @options.buttons
				if button.text.toLowerCase() is buttonAction and typeof button.callback is "function"
					_.delay button.callback, @animationTime

			transition = if env.desktop then 'top' else 'translateY'
			animation = {}
			animation[transition] = -@elem.height() + 'px'
			animation.opacity = 0

			# animate box & overlay into place
			@elem.animate animation, @animationTime, 'swing'

			@overlay.animate { opacity: 0 }, @animationTime

			# Remove all this nonsense
			_.delay =>
				@overlay.remove()
				@close()
			, @animationTime

		# Update position of dialog box when orientation changes
		orientationChange: (e) ->
			@elem.css
				left: (@$el.width() - @elem.width()) / 2

			transition = if env.desktop then 'top' else 'translateY'
			animation = {}
			animation[transition] = if env.desktop then ((@$el.height() - @elem.height()) / 2) + 'px' else ((@$el.height() + @elem.height()) / 2) + 'px'

			# animate box into new position
			@elem.animate animation, @animationTime, 'swing'