# frozen_string_literal: true

if SolidusSupport.backend_available?
  Spree::Core::Engine.routes.draw do
    namespace :admin do
      resources :promotions do
        resources :promotion_rules
        resources :promotion_actions
        resources :promotion_codes, only: [:index, :new, :create]
        resources :promotion_code_batches, only: [:index, :new, :create] do
          get "/download", to: "promotion_code_batches#download", defaults: {format: "csv"}
        end
      end

      resources :promotion_categories, except: [:show]
    end
  end
end

if SolidusSupport.admin_available?
  SolidusAdmin::Engine.routes.draw do
    require "solidus_admin/admin_resources"
    extend SolidusAdmin::AdminResources

    admin_resources :promotions, only: [:index, :destroy]
    admin_resources :promotion_categories, except: [:show]
  end
end
