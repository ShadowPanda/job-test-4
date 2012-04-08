# encoding: utf-8

class CommentsController < NewsController
	before_filter :lookup_parent, :only => [:create]

	def setup
		@model_class = Comment
	end

	def create
		begin
			record = @model_class.new(params[:comment])
			record.user = @current_user
			raise ActiveRecord::RecordInvalid.new(record) if !record.valid?

			@parent.comments << record
			@parent.save!

			render json: {message: "OK", data: record.as_json}
		rescue Exception => e
			render json: {message: "Error occurred: " + e.to_s}, status: 500
		end
	end
end