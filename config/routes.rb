# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, skip: 'registrations'

  devise_scope :user do
    get '/users/sign_up', to: 'devise/registrations#new', as: 'new_registration'
    post '/users/sign_up', to: 'devise/registrations#create', as: nil
  end

  resources :users, except: %i[show new create destroy]

  patch '/users/:id/gender', to: 'users#gender', as: 'get_gender'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root to: 'users#index'
end
