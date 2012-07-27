# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120405103302) do

  create_table "comments", :force => true do |t|
    t.integer  "user_id"
    t.string   "content",          :default => ""
    t.string   "parsed_content",   :default => ""
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  create_table "news", :force => true do |t|
    t.integer  "user_id"
    t.string   "title",      :default => ""
    t.string   "url",        :default => ""
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "questions", :force => true do |t|
    t.integer  "user_id"
    t.string   "title",          :default => ""
    t.string   "content",        :default => ""
    t.string   "parsed_content", :default => ""
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "username",   :default => ""
    t.string   "password",   :default => ""
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "votes", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "positive",      :default => true
    t.integer  "voteable_id"
    t.string   "voteable_type"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

end
