# encoding: utf-8

require File.expand_path('../boot', __FILE__)

require 'rails/all'
require "digest/sha2"

Bundler.require(*Rails.groups(:assets => %w(development test))) if defined?(Bundler)

module JobTest5
	class Application < Rails::Application
		config.encoding = "utf-8"
		config.filter_parameters += [:password]
		config.assets.enabled = true
		config.assets.version = '1.0'
		config.sass.line_comments = false
		config.sass.style = :compact
		config.autoload_paths += [Rails.root + "app/classes"]
	end
end
