Environment.instance().on("loaded", () ->
	switch Environment.instance().get("params").action
		when "index"
			$("#comments-refresh").on("click", () ->
				Router.instance().navigate("comments?page=1", {trigger: true})
				false
			).parent().addClass("active")
)