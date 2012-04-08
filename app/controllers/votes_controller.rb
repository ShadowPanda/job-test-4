# encoding: utf-8

class VotesController < ApplicationController
	before_filter :check_authentication
	before_filter :lookup_parent

	def create
		begin
			if @parent.votes.where(user_id: @current_user.id).count == 0 then
				@parent.votes << Vote.new({user: @current_user, positive: params[:positive].to_boolean})
				@parent.save!
			end

			if request.xhr? then
				render json: {message: "OK", data: Vote.count_for(@parent) }
			else
				redirect_to :root
			end
		rescue Exception => e
			render json: {message: "Error occurred: " + e.to_s}, status: 500
		end
	end
end