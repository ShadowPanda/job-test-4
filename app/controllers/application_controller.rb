# encoding: utf-8

class ApplicationController < ActionController::Base
	protect_from_forgery

	before_filter :authenticate
	before_filter :setup

	def authenticate
		@current_user = nil
		token = cookies["auth-token"].ensure_string

		if token =~ /^((?<id>\d+)(.{128}))$/ then
			id = $~["id"].to_integer

			begin
				@current_user = User.find(id)
				@current_user = nil if @current_user.tokenize != token
			rescue ActiveRecord::RecordNotFound
			end

			cookies.delete("auth-token") if !@current_user
		end
	end

	def check_authentication
		self.authenticate
		render json: {message: "You must be authenticated to perform this request."}, status: 401 if !@current_user
	end

	def lookup_parent
		@parent_class = catch(:klass) do
			throw(:klass, News) if params[:news_id].present?
			throw(:klass, Question) if params[:question_id].present?
			throw(:klass, Comment) if params[:comment_id].present?
			redirect_to :root
		end

		begin
			@parent = @parent_class.find(params[(@parent_class.to_s.parameterize + "_id").to_sym])
		rescue ActiveRecord::RecordNotFound
			redirect_to :root
		end
	end

	def setup

	end
end
