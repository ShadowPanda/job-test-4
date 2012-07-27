# encoding: utf-8

JobTest5::Application.routes.draw do
	match "auth/:action", controller: :auth
	match "rss", to: "news#rss"

	resources :news, :questions, :comments, only: [:index, :create, :show] do
		resources :votes, only: [:create]
		resources :comments, only: [:index, :create, :show]
	end

	root to: "news#index"
end
