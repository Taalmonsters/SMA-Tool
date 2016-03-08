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
  
  get '/users/:user_id/twitter_streams/:id/tweets/poll' => 'twitter_streams#poll_tweets', :as => :poll_stream_tweets
  get '/users/:user_id/twitter_streams/:id/poll' => 'twitter_streams#poll_status', :as => :poll_stream_status
  
  get '/users/:user_id/twitter_searches/:id/tweets/poll' => 'twitter_searches#poll_tweets', :as => :poll_search_tweets
  get '/users/:user_id/twitter_searches/:id/poll' => 'twitter_searches#poll_status', :as => :poll_twitter_search_status
  
  get '/users/:user_id/facebook_searches/:id/facebook_statuses/poll' => 'facebook_searches#poll_status_count', :as => :poll_facebook_statuses
  get '/users/:user_id/facebook_searches/:id/poll' => 'facebook_searches#poll_status', :as => :poll_fb_search_status
end
