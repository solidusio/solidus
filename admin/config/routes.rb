# frozen_string_literal: true

SolidusAdmin::Engine.routes.draw do
  resources :orders, only: :index
end
