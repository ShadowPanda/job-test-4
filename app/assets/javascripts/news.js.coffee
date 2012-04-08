Environment.instance().on("loaded", () ->
	switch Environment.instance().get("params").action
		when "index"
			$("#news-refresh").on("click", () ->
				Router.instance().navigate("news?page=1", {trigger: true})
				false
			).parent().addClass("active")

	news_dialog = new NewsDialog()
)