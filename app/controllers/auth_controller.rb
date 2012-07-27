# encoding: utf-8

class AuthController < ApplicationController
	skip_before_filter :authenticate, only: :login

	def login
		begin
			user = params[:user]
			user[:password] = User.encrypt(user[:password])

			valid_user = User.where(user).first

			if valid_user then
				cookies["auth-token"] = {value: valid_user.tokenize, path: "/", expire: 1.hours.from_now}
				render json: {message: "OK"}
			else
				render json: {message: "Invalid username or password."}, status: 401
			end
		rescue Exception => e
			render json: {message: e.to_s}, status: 500
		end
	end

	def logout
		cookies.delete("auth-token")
		redirect_to :root
	end

	def register
		begin
			user = params[:user]
			user.delete(:confirm_password)

			valid_user = User.create!(user)
			cookies["auth-token"] = {value: valid_user.tokenize, path: "/", expire: 1.hours.from_now}
			render json: {message: "OK"}
		rescue ActiveRecord::RecordInvalid => e
			render json: {message: "Username has already be taken."}, status: 403
		rescue Exception => e
			render json: {message: "Error occurred: " + e.to_s}, status: 500
		end
	end
end