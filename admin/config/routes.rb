# frozen_string_literal: true

SolidusAdmin::Engine.routes.draw do
  resource :account, only: :show
  resources :products, only: :index
end
