module Common
	extend ActiveSupport::Concern

	def parse_content
		self.parsed_content = Kramdown::Document.new(self.content).to_html if self.content_changed?
	end

	module ClassMethods
		def per_page
			25
		end

		def fetch(params = {}, add_metadata = false, as_json = true)
			rv = nil

			count = params.fetch(:count, -1).to_integer
			offset = params.fetch(:offset, 0).to_integer

			query = self.order("created_at DESC")
			query = query.offset([offset, 0].max) if offset > 0
			query = query.limit([count, 0].max) if count > -1

			if as_json then
				i = 0
				rv = query.collect { |record|
					i += 1
					record.as_json.merge({:index => offset + i})
				}
			else
				rv = query.all
			end

			rv = {params: params, data: rv, total: self.count } if add_metadata
			rv
		end
	end
end