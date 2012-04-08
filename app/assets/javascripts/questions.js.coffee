Environment.instance().on("loaded", () ->
	switch Environment.instance().get("params").action
		when "index"
			$("#questions-refresh").on("click", () ->
				Router.instance().navigate("questions?page=1", {trigger: true})
				false
			).parent().addClass("active")

	question_dialog = new QuestionDialog()
)