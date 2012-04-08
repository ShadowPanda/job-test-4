class @Environment extends Backbone.Model
	_instance: null

	@instance: (() ->
		@_instance = new @ if !@_instance?
		@_instance
	)

class @Router extends Backbone.Router
	_instance: null

	routes: {
		"news?page=:page": "newsPage"
		"comments?page=:page": "commentsPage"
		"questions?page=:page": "questionsPage"
		"*actions": "onChange"
	}

	@instance: (() ->
		@_instance = new @ if !@_instance?
		@_instance
	)

	@setup: (() ->
		@_instance = new @
		Backbone.history.start({pushState: true})
	)

	newsPage: ((page) ->
		link = $(NewsList.page_template({url: Environment.instance().get("paginator-url-news").replace("__page__", page), direction: "", klass: "", label: ""}))
		$("#news-paginator").append(link)
		link.click()
	)

	commentsPage: ((page) ->
		link = $(CommentsList.page_template({url: Environment.instance().get("paginator-url-comments").replace("__page__", page), direction: "", klass: "", label: ""}))
		$("#comments-paginator").append(link)
		link.click()
	)

	questionsPage: ((page) ->
		link = $(QuestionsList.page_template({url: Environment.instance().get("paginator-url-questions").replace("__page__", page), direction: "", klass: "", label: ""}))
		$("#questions-paginator").append(link)
		link.click()
	)

	onChange: (() ->)

_.templateSettings = {
  interpolate : /[\{\[_]{2}([\s\S]+?)[\}\]_]{2}/g
};

