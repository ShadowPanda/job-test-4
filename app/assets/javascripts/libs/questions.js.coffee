class @Question extends Backbone.Model

class @QuestionsStore extends Backbone.Collection
	model: Question

class @QuestionView extends Backbone.View
	tagName: "article"
	className: "question element container-fluid row-fluid"

	events:
		"ajax:before .vote": "checkUser"
		"ajax:success .vote": "onVoted"

	initialize: ((options = {}, single = true) ->
		Backbone.View::initialize.call(this, options)
		@single = single
	)

	render: (() ->
		tmpl = _.template($("#templates-question-#{if @single then "single" else "multi"}").html())
		@$el.html(tmpl(@model.toJSON()))
		@$el.attr("id", "question-#{@model.get("id")}")

		if @single
			# Add reply
			if !_.isBlank(Environment.instance().get("user"))
				@$el.find("> div").removeClass("alert")
				form = new CommentForm({model: @model}, this)
				form.renderTo(@$el)

			# Render comments
			@$el.addClass("single")
			@comments = new CommentsList(@model.get("comments"))
			@comments.renderTo(@$el)


		this
	)

	renderTo: ((container, prepend = false) ->
		@render()
		if prepend then @$el.prependTo(container) else @$el.appendTo(container)
	)

	checkUser: (() ->
		valid = true

		if _.isBlank(Environment.instance().get("user"))
			valid = "You must be logged to vote."

		if valid != true
			dialog = $("""
			<div class="alert alert-error">
				<a class="close" data-dismiss="alert" href="#"><i class="icon-remove"></i></a>
				<h4 class="alert-heading">#{valid}</h4>
			</div>
			""").appendTo($("#alerts")).alert()

			setTimeout((() ->
				dialog.slideUp("fast", (() ->
					$(this).remove()
				))
			), 3000)

			valid = false

		valid
	)

	onVoted: ((ev, data, status, jqxhr) ->
		root = $(ev.currentTarget).parent()
		if @model.get("votes").ups != data.data.ups
			root.find(".votes-ups").text(data.data.ups).parent().hide().fadeIn("fast")
		if @model.get("votes").downs != data.data.downs
			root.find(".votes-downs").text(data.data.downs).parent().hide().fadeIn("fast")

		@model.set("votes", data.data)
	)

class @QuestionsList extends Backbone.View
	el: "#questions-list"

	@page_template: _.template("""<a href="{{url}}" data-remote="true" data-type="json" class="btn btn-secondary {{klass}} questions-paginator-button"><i class="icon-chevron-{{direction}}"></i> {{label}}</a>""")

	events:
		"ajax:before .questions-paginator-button": "onBeforeChangePage"
		"ajax:error .questions-paginator-button": "onPageChangeFailed"
		"ajax:success .questions-paginator-button": "onPageChanged"

	initialize: ((data = {}) ->
		@collection = new QuestionsStore(data.data)
		@collection.url = Environment.instance().get("paginator-url-questions")
		@render()

		$("""<div class="alert alert-warning"><h4 class="alert-heading"><i class="icon-error"></i> No questions asked.</h4></div>""").appendTo(@$el.find("#questions-container")) if @collection.length == 0

		paginator = @$el.find("#questions-paginator")

		if data.params.page > 1
			$(QuestionsList.page_template({url: @collection.url.replace("__page__", data.params.page - 1), direction: "left", klass: "pull-left", label: "Newer question"})).appendTo(paginator)
		if data.params.offset + data.params.count < data.total
			$(QuestionsList.page_template({url: @collection.url.replace("__page__", data.params.page + 1), direction: "right", klass: "pull-right", label: "Older question"})).appendTo(paginator)
	)

	render: ((internal = true) ->
		view = this
		container = @$el.find("#questions-container")

		_.each(@collection.models, (item) ->
			question = new QuestionView({model: item}, false)
			question.renderTo(container)
		)
	)

	showLoadingMessage: (() ->
		@message = $("""<div id="alert-question-loading" class="alert alert-warning alert-loading"><h4 class="alert-heading"><i class="icon-refresh"></i> Loading questions. Please wait ...</h4></div>""").appendTo($("#alerts")).slideDown()
	)

	onBeforeChangePage: (() ->
		@message.remove? if @message?

		@collection.reset({}, {silent: true})
		@$el.find("#questions-container").prepend($("""<div class="questions-container-overlay"></div>"""))
		@showLoadingMessage()
	)

	onPageChangeFailed: ((ev, jqxhr, status, error) ->
		@message.remove() if @message?

		data = $.parseJSON(jqxhr.responseText)
		@message = $("""<div id="alert-questions-loading" class="alert alert-error"><h4 class="alert-heading">Unable to load questions.</h4><p>#{data.message}</p></div>""").appendTo($("#alerts"))
	)

	onPageChanged: ((ev, data, status, jqxhr) ->
		url = $(ev.target).attr("href")
		@$el.find("#questions-container").html("")
		@$el.find("#questions-paginator").html("")

		@initialize(data)
		@onPageChangeComplete()
		Router.instance().navigate(url)
	)

	onPageChangeComplete: (() ->
		@message.slideUp("fast", () ->
			$(this).remove()
		)
	)

class @QuestionDialog extends Backbone.View
	el: "#dialogs-submit-question"

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
		@$el.find(".btn-success").remove()
		@$el.find("button").show()
		@$el.find("[id^=question]").val("")
	)

	getActionData: (() ->
		data = {}
		@$el.find("[id^=question]").each(() ->
			field = $(this)
			data[field.attr("id").replace("question_", "")] = field.val()
		)

		data
	)

	onBeforeAction: (() ->
		data = @getActionData()
		valid = true
		@cleanUp()

		if _.isBlank(data.title) || _.isBlank(data.content)
			valid = "Please insert title and description."

		if valid == true
			@$el.find("button").find("span").text("Saving question ...")
		else
			$("""<div class="alert alert-error alert-block"><h4 class="alert-heading">#{valid}</h4></div>""").prependTo(@$el.find(".modal-body"))
			@onActionCompleted()
			valid = false

		valid
	)

	onActionSuccess: (() ->
		dialog = this
		$("""<div class="alert alert-success alert-block"><h4 class="alert-heading">Question saved successfully.</h4><p>You can now close this dialog.</p></div>""").prependTo(@$el.find(".modal-body"))
		@$el.find("button").hide()
		$("""<button type="reset" class="btn btn-success"><i class="icon-remove"></i> Close</button>""").prependTo(@$el.find(".modal-footer")).on("click", ->
			dialog.$el.modal("hide")
			Router.instance().questionsPage(1)
		)
	)

	onActionError: ((ev, jqxhr, status, error) ->
		data = $.parseJSON(jqxhr.responseText)
		$("""<div class="alert alert-error alert-block"><h4 class="alert-heading">#{data.message}</h4></div>""").prependTo(@$el.find(".modal-body"))
	)

	onActionCompleted: (() ->
		@$el.find("button").removeAttr("disabled").find("span").text("Ask")
	)