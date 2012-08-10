###
Main controller
	- Handles instantiating all game view objects and switching between them
	- Inits sound manager
###
define [
	'jquery'
	'underscore'
	'backbone'
	'buzz'
	'cs!utilities/env'
	'cs!views/title'
	'cs!views/game'
	'cs!views/about'
	'cs!views/options'
	'cs!views/level-select'
	'cs!views/difficulty-select'
], ($, _, Backbone, buzz, env, TitleScene, GameScene, AboutScene, OptionsScene, LevelSelectScene, DifficultySelectScene) ->
	
	# Extend local storage
	Storage.prototype.setObject = (key, value) ->
	    @setItem key, JSON.stringify value

	Storage.prototype.getObject = (key) ->
    	value = @getItem key
	    return value and JSON.parse value

	# Extend Backbone
	Backbone.View.prototype.close = ->
		@elem.remove()
		@undelegateEvents()

		if typeof @onClose == "function"
			@onClose()

	# Define app obj
	class App extends Backbone.View
		events:
			'orientationchange': 'orientationChange'

		el: null
		activeScene: null

		initialize: ->
			# Create all game views here
			@el = if @options.el? then @options.el else $('#app')
			@titleScene = new TitleScene { el: @el }
			@gameScene = new GameScene { el: @el }
			@aboutScene = new AboutScene { el: @el }
			@optionsScene = new OptionsScene { el: @el }
			@levelScene = new LevelSelectScene { el: @el }
			@difficultyScene = new DifficultySelectScene { el: @el }

			# Bind handlers on each view to allow easy switching between scenes
			@titleScene.on 'scene:change', @changeScene, @
			@gameScene.on 'scene:change', @changeScene, @
			@aboutScene.on 'scene:change', @changeScene, @
			@optionsScene.on 'scene:change', @changeScene, @
			@levelScene.on 'scene:change', @changeScene, @
			@difficultyScene.on 'scene:change', @changeScene, @

			# Hide all scenes (instantly)
			@titleScene.hide 0
			@gameScene.hide 0
			@aboutScene.hide 0
			@optionsScene.hide 0
			@levelScene.hide 0
			@difficultyScene.hide 0

			# Set "active" scene
			@activeScene = @titleScene

			# Show the active scene when call stack is empty
			_.defer =>
				if env.cordova and env.ios then cordova.exec(null, null, "SplashScreen", "hide", [])	# Manually remove the Cordova splash screen; prevent a white flash while UIWebView is initialized
				@activeScene.show()

			# Add an additional class to game container if "installed" on iOS homescreen - currently unused
			if window.navigator.standalone then @el.addClass 'standalone'

			# Do an initial resize of the content area to ensure a 2:3 ratio
			@resize()

			# Listen for resize events on desktop
			if env.desktop then $(window).on 'resize', $.proxy(@resize, @)

		# Handle hiding/showing the active scene
		changeScene: (scene, options) ->
			@activeScene.hide()

			switch scene
				when 'title' then @activeScene = @titleScene
				when 'about' then @activeScene = @aboutScene
				else
					console.log "Error! Scene not defined in switch statement" 
					@activeScene = @titleScene

			@activeScene.show()

		# Handle an orientation change on mobile
		orientationChange: (e) ->
			if window.outerWidth > window.outerHeight
				@el.removeClass('portrait').addClass('landscape')
			else
				@el.removeClass('landscape').addClass('portrait')

		# Called once when app initializes; again if user manually resizes browser window
		resize: (e) ->
			# Attempt to force a 2:3 aspect ratio, so that the percentage-based CSS layout is consistant
			width = window.outerWidth
			height = window.outerHeight

			# This obj will be used to store how much padding is needed for each scene's container
			padding = 
				width: 0
				height: 0

			if width > height
				@el.addClass 'landscape'
				orientation = 'landscape'
			else 
				@el.removeClass 'landscape'
				orientation = 'portrait'

			# Aspect ratio to enforce
			ratio = 3 / 2

			# Tweet: Started writing some commented-out psuedocode, but it turned out to be CoffeeScript, so I uncommented it.
			if orientation is 'landscape'
				if width / ratio > height 		# Too wide; add padding to width
					newWidth = height * ratio
					padding.width = width - newWidth
					width = newWidth
				else if width / ratio < height 	# Too high; add padding to height
					newHeight = width / ratio
					padding.height = height - newHeight
					height = newHeight

				$('body').css { 'font-size': "#{width * 0.1302}%" }		# Dynamically update the font size - 0.1302% font size per pixel in width

			else if orientation is 'portrait'
				if height / ratio > width 		# Too high; add padding to height
					newHeight = width * ratio
					padding.height = height - newHeight
					height = newHeight
				else if height / ratio < width 	# Too wide, add padding to width
					newWidth = height / ratio
					padding.width = width - newWidth
					width = newWidth

				$('body').css { 'font-size': "#{height * 0.1302}%" }	# Dynamically update the font size - 0.1302% font size per pixel in height

			# Add the calculated padding to each scene <div>
			@el.find('.scene .container').css
				width: width
				height: height
				padding: "#{padding.height / 2}px #{padding.width / 2}px"

			# Call a "resize" method on views that need it
			@gameScene.resize width, height, orientation
			@levelScene.resize width, height, orientation

	# Wait until "deviceready" event is fired, if necessary (Cordova only)
	if env.cordova
		document.addEventListener "deviceready", ->
			window.app = new App
		, false
	else
		window.app = new App
	