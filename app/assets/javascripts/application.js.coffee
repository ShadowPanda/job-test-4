#= require jquery
#= require jquery_ujs
#= require backbone-rails
#= require bootstrap-alert
#= require bootstrap-dropdown
#= require bootstrap-modal
#= require libs/environment
#= require libs/auth
#= require libs/comments
#= require libs/news
#= require libs/questions

if !String::trim?
	String::trim = (->
		@replace /(^\s+)|(\s+$)/g, ""
	)

_.mixin(
	isBlank: ((obj) ->
		_.isNull(obj) || _.isUndefined(obj) || (_.isString(obj) && obj.trim().length == 0) || (_.isArray(obj) && _.isEmpty(obj))
	)
)

jQuery(document).ready(($) ->
	# Authentication and signing stuff
	if ! $("body").hasClass("logged")
		login_dialog = new LoginDialog()
		register_dialog = new RegisterDialog()

	Environment.instance().trigger("loaded")

	# Router
	Router.setup()
)