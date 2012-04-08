class @Comment extends Backbone.Model

class @CommentsStore extends Backbone.Collection
	model: Comment

class @CommentView extends Backbone.View
	tagName: "article"
	className: "comment element container-fluid"

	events:
		"ajax:before .vote": "checkUser"
		"ajax:success .vote": "onVoted"

	initialize: ((options = {}, single = true) ->
		Backbone.View::initialize.call(this, options)
		@single = single
	)

	render: (() ->
		tmpl = _.template($("#templates-comment-#{if @single then "single" else "multi"}").html())
		@$el.html(tmpl(@model.toJSON()))
		@$el.attr("id", "comment-#{@model.get("id")}")
		@$el.addClass("single") if @single

		# Add the reply form
		if @single && !_.isBlank(Environment.instance().get("user"))
			@$el.find("> div").removeClass("alert")
			form = new CommentForm({model: @model}, this)
			form.renderTo(@$el)

		if Environment.instance().get("comments-skip-replies") != true
			# Render replies
			@comments = new CommentsList(@model.get("comments"))
			@comments.renderTo(@$el)

		this
	)

	renderTo: ((container, prepend = false) ->
		@render()
		if prepend then @$el.prependTo(container) else @$el.appendTo(container)
	)

	markNew: (() ->
		view = this
		@$el.find("> div").addClass("alert-success").hide().slideDown("fast")

		setTimeout((() ->
			view.$el.find("> div").removeClass("alert-success")
		), 3000)
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

class @CommentsList extends Backbone.View
	tagName: "div"
	className: "comments-container"

	@page_template: _.template("""<a href="{{url}}" data-remote="true" data-type="json" class="btn btn-secondary {{klass}} comments-paginator-button"><i class="icon-chevron-{{direction}}"></i> {{label}}</a>""")

	events:
		"ajax:before .comments-paginator-button": "onBeforeChangePage"
		"ajax:error .comments-paginator-button": "onPageChangeFailed"
		"ajax:success .comments-paginator-button": "onPageChanged"

	initialize: ((data = {}) ->
		if !_.isObject(data.data)
			@collection = new CommentsStore(data)
		else
			@setElement($("#comments-list"))
			@collection = new CommentsStore(data.data)
			@collection.url = Environment.instance().get("paginator-url-comments")
			@render()

			$("""<div class="alert alert-warning"><h4 class="alert-heading"><i class="icon-error"></i> No comments posted.</h4></div>""").appendTo(@$el.find("#comments-container")) if @collection.length == 0

			paginator = @$el.find("#comments-paginator")

			if data.params.page > 1
				$(CommentsList.page_template({url: @collection.url.replace("__page__", data.params.page - 1), direction: "left", klass: "pull-left", label: "Newer comments"})).appendTo(paginator)
			if data.params.offset + data.params.count < data.total
				$(CommentsList.page_template({url: @collection.url.replace("__page__", data.params.page + 1), direction: "right", klass: "pull-right", label: "Older comments"})).appendTo(paginator)
	)

	render: ((internal = true) ->
		view = this

		_.each(@collection.models, (item) ->
			view.renderComment(item, internal)
		)
	)

	renderComment: ((item, internal = true, prepend = false) ->
		comment = new CommentView({model: item}, false)
		comment.renderTo((if @$el.is(".comments-container") then @$el else @$el.find("#comments-container")), prepend)
		comment.markNew() if !internal
	)

	renderTo: ((container, prepend = false) ->
		@render()
		if prepend then @$el.prependTo(container) else @$el.appendTo(container)
	)

	showLoadingMessage: (() ->
		@message = $("""<div id="alert-comments-loading" class="alert alert-warning alert-loading"><h4 class="alert-heading"><i class="icon-refresh"></i> Loading comments. Please wait ...</h4></div>""").appendTo($("#alerts")).slideDown()
	)

	onBeforeChangePage: (() ->
		@message.remove() if @message?

		@collection.reset({}, {silent: true})
		@$el.find("#comments-container").prepend($("""<div class="comments-container-overlay"></div>"""))
		@showLoadingMessage()
	)

	onPageChangeFailed: ((ev, jqxhr, status, error) ->
		@message.remove() if @message?

		data = $.parseJSON(jqxhr.responseText)
		@message = $("""<div id="alert-comments-loading" class="alert alert-error"><h4 class="alert-heading">Unable to load comments.</h4><p>#{data.message}</p></div>""").appendTo($("#alerts"))
	)

	onPageChanged: ((ev, data, status, jqxhr) ->
		url = $(ev.target).attr("href")
		@$el.find("#comments-container").html("")
		@$el.find("#comments-paginator").html("")

		@initialize(data)
		@onPageChangeComplete()
		Router.instance().navigate(url)
	)

	onPageChangeComplete: (() ->
		@message.slideUp("fast", () ->
			$(this).remove()
		)
	)

	@label_for: ((amount, empty = "Discuss") ->
		rv = empty

		if amount == 1
			rv = "1 comment"
		else if amount > 1
			rv = "#{amount} comments"

		rv
	)

class @CommentForm extends Backbone.View
	tagName: "div"
	className: "comment-form"

	initialize: ((options, parent) ->
		Backbone.View::initialize.call(this, options)
		@parent  = parent
	)

	events:
		"ajax:before": "onBeforeAction"
		"ajax:success": "onActionSuccess"
		"ajax:error": "onActionError"
		"ajax:complete": "onActionCompleted"

	render: (() ->
		tmpl = _.template($("#templates-comment-form").html())
		@label = "Add comment"
		@type = "news"

		if @model instanceof Question
			@type = "questions"
		else
		if @model instanceof Comment
			@label = "Reply"
			@type = "comments"

		@$el.html(tmpl({label: @label, url: Environment.instance().get("urls-comments")[@type].replace("__id__", @model.get("id"))}))
	)

	renderTo: ((container, prepend = false) ->
		@render()
		if prepend then @$el.prependTo(container) else @$el.appendTo(container)
	)

	cleanUp: (() ->
		@$el.find("div.alert").remove()
	)

	reset: (() ->
		@cleanUp()
		@$el.find("textarea").val("")
	)

	getActionData: (() ->
		data = {content: @$el.find("textarea").val()}
	)

	onBeforeAction: (() ->
		data = @getActionData()
		valid = true
		@cleanUp()

		if _.isBlank(data.content)
			valid = "Please insert a comment."

		if valid == true
			@$el.find("button").attr("disabled", "disabled").find("span").text("Submitting data. Please wait ...")
		else
			$("""<div class="alert alert-error alert-block"><h4 class="alert-heading">#{valid}</h4></div>""").prependTo(@$el)
			@onActionCompleted()
			valid = false

		valid
	)

	onActionSuccess: ((ev, data, status, jqxhr) ->
		@parent.comments.collection.unshift(data.data)
		@parent.comments.renderComment(@parent.comments.collection.at(0), false, true)
		@parent.$el.find(".comments-count").text(CommentsList.label_for(@parent.comments.collection.length, "No comments")).parent().hide().fadeIn("fast")
	)

	onActionError: ((ev, jqxhr, status, error) ->
		data = $.parseJSON(jqxhr.responseText)
		$("""<div class="alert alert-error alert-block"><h4 class="alert-heading">#{data.message}</h4></div>""").prependTo(@$el)
	)

	onActionCompleted: (() ->
		@$el.find("button").removeAttr("disabled").find("span").text(@label)
		@$el.find("textarea").val("")
	)