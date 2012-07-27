# encoding: utf-8

class NewsController < ApplicationController
	before_filter :check_authentication, except: [:index, :show, :rss]

	def setup
		@model_class = News
	end

	def index
		@paginator = {
			page: [1, params[:page].to_integer].max,
			count: [@model_class.per_page, params[:count].to_integer].max
		}
		@paginator[:offset] = (@paginator[:page] - 1) * @paginator[:count]

		if request.xhr? then
			records = @model_class.fetch(@paginator, true)
			render json: records
		else
			@records = @model_class.fetch(@paginator, true)
		end
	end

	def create
		begin
			record = @model_class.new(params[@model_class.to_s.parameterize.to_sym])
			record.user = @current_user
			record.save!

			render json: {message: "OK"}
		rescue Exception => e
			render json: {message: "Error occurred: " + e.to_s}, status: 500
		end
	end

	def show
		begin
			@record = @model_class.find(params[:id])
		rescue ActiveRecord::RecordNotFound
			redirect_to action: :index
		end
	end

	def rss
		@records = @model_class.fetch({}, false, false)
		render :rss => @records
	end
end