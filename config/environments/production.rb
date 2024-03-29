# encoding: utf-8

JobTest5::Application.configure do
  config.cache_classes = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.assets.compress = true
  config.assets.compile = false
  config.assets.precompile << "*.js"
  config.assets.precompile << "*.css"
  config.assets.digest = true
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
end
