# encoding: utf-8

class CreateAll < ActiveRecord::Migration
  def up
	  create_table :users do |t|
		  t.string :username, default: ""
		  t.string :password, default: ""
		  t.timestamps
	  end

	  create_table :news do |t|
		  t.integer :user_id, default: nil
		  t.string :title, default: ""
		  t.string :url, default: ""
		  t.timestamps
	  end

	  create_table :questions do |t|
		  t.integer :user_id, default: nil
		  t.string :title, default: ""
		  t.string :content, default: ""
		  t.string :parsed_content, default: ""
		  t.timestamps
	  end

	  create_table :comments do |t|
		  t.integer :user_id, default: nil
		  t.string :content, default: ""
		  t.string :parsed_content, default: ""
		  t.references :commentable, polymorphic: true
		  t.timestamps
	  end

	  create_table :votes do |t|
		  t.integer :user_id, default: nil
		  t.boolean :positive, default: true
		  t.references :voteable, polymorphic: true
		  t.timestamps
	  end
  end

  def down
	  drop_table :users
	  drop_table :news
	  drop_table :questions
	  drop_table :comments
	  drop_table :votes
  end
end
