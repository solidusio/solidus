# frozen_string_literal: true

SolidusPromotions::Engine.routes.draw do
  if SolidusSupport.admin_available?
    require "solidus_admin/admin_resources"
    extend SolidusAdmin::AdminResources

    constraints(->(request) {
                  request.cookies["solidus_admin"] == "true" ||
                    request.params["solidus_admin"] == "true" ||
                    SolidusPromotions.config.use_new_admin?
                }) do
      scope :admin do
        scope :solidus do
          admin_resources :promotion_categories, except: [:show]
          admin_resources :promotions, only: [:index, :destroy]
        end
      end
    end
  end
  if SolidusSupport.backend_available?
    namespace :admin do
      scope :solidus do
        resources :promotion_categories, except: [:show]

        resources :promotions do
          resources :benefits do
            resources :conditions
          end
          resources :promotion_codes, only: [:index, :new, :create]
          resources :promotion_code_batches, only: [:index, :new, :create] do
            get "/download", to: "promotion_code_batches#download", defaults: { format: "csv" }
          end
        end
      end
    end
  end
end
