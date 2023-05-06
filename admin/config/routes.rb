# frozen_string_literal: true

SolidusAdmin::Engine.routes.draw do
  resources :roles, controller: 'solidus_admin/roles'
end
