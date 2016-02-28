Rails.application.routes.draw do

  root to: 'visitors#index'
  get '/auth/:provider/callback' => 'sessions#create'
  get '/signin' => 'sessions#new', :as => :signin
  get '/signout' => 'sessions#destroy', :as => :signout
  get '/auth/failure' => 'sessions#failure'
  
  resources :users do
    resources :twitter_streams
    resources :twitter_searches
    resources :twitter_id_searches
    resources :facebook_searches
  end
  
  post '/users/:user_id/twitter_streams/:id/stop' => 'twitter_streams#stop'
  post '/users/:user_id/twitter_searches/:id/stop' => 'twitter_searches#stop'
  post '/users/:user_id/facebook_searches/:id/stop' => 'facebook_searches#stop'
end
