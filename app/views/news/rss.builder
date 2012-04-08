xml.instruct!(:xml, version: "1.0")

xml.rss(version: "2.0") do
	xml.channel do
		xml.title "Hacker News"
		xml.description "A simple test"
		xml.link url_for(controller: :news, action: :index, only_path: false)

		@records.each do |record|
			xml.item do
				xml.title record.title
				xml.description record.title
				xml.pubDate record.created_at.to_s(:rfc822)
				xml.link record.url
				xml.guid "news-#{record.id}"
			end
		end
	end
end