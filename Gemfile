# encoding: utf-8

source "https://rubygems.org"

# General
gem "rails", "3.2.1"
gem "cowtech-extensions"
gem "pry-rails"
gem "simple_form"
gem "kramdown"

# Style
gem "sass-rails"
gem "compass", "~> 0.12beta"
gem "compass-rails"
gem "compass_twitter_bootstrap"
gem "font-awesome-rails"

# Javascripts
gem "jquery-rails"
gem "coffee-rails"
gem "backbone-rails", git: "https://github.com/ShogunPanda/backbone-rails.git", branch: "master"

group :development, :test do
  gem "sqlite3"
end

group :production, :staging do
  gem "pg"
  gem "uglifier"
end
