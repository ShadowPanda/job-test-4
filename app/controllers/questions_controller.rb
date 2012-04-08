# encoding: utf-8

class QuestionsController < NewsController
	def setup
		@model_class = Question
	end
end