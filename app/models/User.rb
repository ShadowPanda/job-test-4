# encoding: utf-8

class User < ActiveRecord::Base
	has_many :news
	has_many :questions
	has_many :votes
	has_many :comments

	validates :username, uniqueness: true

	def self.encrypt(plain)
		Digest::SHA2.hexdigest(plain)
	end

	def password=(value)
		write_attribute(:password, self.class.encrypt(value))
	end

	def tokenize
		[self.id, self.class.encrypt(self.username), self.password].join("")
	end

	def as_json(options = {})
		{
			id: self.id,
			username: self.username,
			created_at: self.created_at.strftime("%F %T")
		}
	end
end