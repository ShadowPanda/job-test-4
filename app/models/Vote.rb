# encoding: utf-8

class Vote < ActiveRecord::Base
	belongs_to :user

	scope :ups, conditions: {positive: true}
	scope :downs, conditions: {positive: false}

	def self.count_for(obj)
		{ups: obj.votes.ups.count, downs: obj.votes.downs.count}
	end
end