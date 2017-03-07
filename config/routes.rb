Rails.application.routes.draw do
  resources :orders
  get 'sessions/new'

  root 'static_pages#home'
  get '/home', to: 'static_pages#home'
  get '/contact', to: 'static_pages#contact'
  get '/signup', to: 'users#new'
  get '/login',   to: 'sessions#new'
  post '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'

  resources :promocodes
  resources :users
  resources :watches
  resources :macs
  resources :iphones
  resources :orders
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
end
