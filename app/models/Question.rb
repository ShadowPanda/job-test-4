# encoding: utf-8

class Question < ActiveRecord::Base
	include ::Common

	belongs_to :user
	has_many :comments, as: :commentable, order: "updated_at DESC"
	has_many :votes, as: :voteable, order: "updated_at DESC"

	validates :title, :content, presence: true
	before_save :parse_content

	def as_json(options = {})
		rv = {
			id: self.id,
			title: self.title,
			content: self.parsed_content,
			user: self.user.as_json,
			created_at: self.created_at.strftime("%F %T"),
			votes: Vote.count_for(self),
			comments: self.comments.as_json
		}
	end
end