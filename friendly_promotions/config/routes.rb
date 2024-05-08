# frozen_string_literal: true

SolidusFriendlyPromotions::Engine.routes.draw do
  namespace :admin do
    scope :friendly do
      resources :promotion_categories, except: [:show]

      resources :promotions do
        resources :promotion_actions do
          resources :conditions
        end
        resources :promotion_codes, only: [:index, :new, :create]
        resources :promotion_code_batches, only: [:index, :new, :create] do
          get "/download", to: "promotion_code_batches#download", defaults: {format: "csv"}
        end
      end
    end
  end
end
