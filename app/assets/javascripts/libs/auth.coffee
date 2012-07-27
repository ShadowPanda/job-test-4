class @LoginDialog extends Backbone.View
	el: "#dialogs-auth-login"

	initialize: (() ->
		dialog = this
		@$el.on("shown", ->
			dialog.reset()
		)
	)

	events:
		"ajax:before": "onBeforeAction"
		"ajax:success": "onActionSuccess"
		"ajax:error": "onActionError"
		"ajax:complete": "onActionCompleted"

	cleanUp: (() ->
		@$el.find("div.alert").remove()
	)

	reset: (() ->
		@cleanUp()
		@$el.find("input[id^=user]").val("")
	)

	getActionData: (() ->
		data = {}
		@$el.find("input[id^=user]").each(() ->
			field = $(this)
			data[field.attr("id").replace("user_", "")] = field.val()
		)

		data
	)

	onBeforeAction: (() ->
		data = @getActionData()
		valid = true
		@cleanUp()

		if _.isBlank(data.username) || _.isBlank(data.password)
			valid = "Please insert your username and password."

		if valid == true
			@$el.find("button").attr("disabled", "disabled").find("span").text("Logging in ...")
		else
			$("""<div class="alert alert-error alert-block"><h4 class="alert-heading">#{valid}</h4></div>""").prependTo(@$el.find(".modal-body"))
			@onActionCompleted()
			valid = false

		valid
	)

	onActionSuccess: (() ->
		$("""<div class="alert alert-success alert-block"><h4 class="alert-heading">Logged in successfully.</h4></div>""").prependTo(@$el.find(".modal-body"))
		@$el.modal("hide")
		location.reload()
	)

	onActionError: ((ev, jqxhr, status, error) ->
		data = $.parseJSON(jqxhr.responseText)
		$("""<div class="alert alert-error alert-block"><h4 class="alert-heading">#{data.message}</h4></div>""").prependTo(@$el.find(".modal-body"))
	)

	onActionCompleted: (() ->
		@$el.find("button").removeAttr("disabled").find("span").text("Login")
	)

class @RegisterDialog extends LoginDialog
	el: "#dialogs-auth-register"

	onBeforeAction: (() ->
		data = @getActionData()
		valid = true
		@cleanUp()

		if _.isBlank(data.username) || _.isBlank(data.password)
			valid = "Please insert your new username and password."
		else if data.password != data.confirm_password
			valid = "Passwords don't match"

		if valid == true
			@$el.find("button").attr("disabled", "disabled").find("span").text("Registering ...")
		else
			$("""<div class="alert alert-error alert-block"><h4 class="alert-heading">#{valid}</h4></div>""").prependTo(@$el.find(".modal-body"))
			@onActionCompleted()
			valid = false

		valid
	)

	onActionSuccess: (() ->
		$("""<div class="alert alert-success alert-block"><h4 class="alert-heading">Registered successfully.</h4></div>""").prependTo(@$el.find(".modal-body"))
		@$el.modal("hide")
		location.reload()
	)

	onActionCompleted: (() ->
		@$el.find("button").removeAttr("disabled").find("span").text("Register")
	)