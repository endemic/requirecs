###
Try to determine some basic info about the current environment
###
define () ->
	agent = navigator.userAgent.toLowerCase()

	android = agent.match(/android/i)
	android = android?.length > 0
	ios = agent.match(/ip(hone|od|ad)/i)
	ios = ios?.length > 0
	
	mobile = android or ios
	desktop = not mobile
 
	return {
		android: android
		ios: ios
		mobile: mobile
		desktop: desktop
		cordova: typeof cordova != "undefined"
	}