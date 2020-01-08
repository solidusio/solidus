# frozen_string_literal: true

Spree::Core::Engine.routes.draw do
  namespace :admin do
    get '/search/users', to: "search#users", as: :search_users
    get '/search/products', to: "search#products", as: :search_products

    put '/locale/set', to: 'locale#set', defaults: { format: :json }, as: :set_locale

    resources :dashboards, only: [] do
      collection do
        get :home
      end
    end

    resources :promotions do
      resources :promotion_rules
      resources :promotion_actions
      resources :promotion_codes, only: [:index, :new, :create]
      resources :promotion_code_batches, only: [:index, :new, :create] do
        get '/download', to: "promotion_code_batches#download", defaults: { format: "csv" }
      end
    end

    resources :promotion_categories, except: [:show]

    resources :zones

    resources :tax_categories

    resources :products do
      resources :product_properties do
        collection do
          post :update_positions
        end
      end
      resources :variant_property_rule_values, only: [:destroy] do
        collection do
          post :update_positions
        end
      end
      resources :images do
        collection do
          post :update_positions
        end
      end
      member do
        post :clone
      end
      resources :variants, only: [:index, :edit, :update, :new, :create, :destroy] do
        collection do
          post :update_positions
        end
      end
      resources :variants_including_master, only: [:update]
      resources :prices, only: [:destroy, :index, :edit, :update, :new, :create]
    end
    get '/products/:product_slug/stock', to: "stock_items#index", as: :product_stock

    resources :option_types do
      collection do
        post :update_positions
        post :update_values_positions
      end
    end

    delete '/option_values/:id', to: "option_values#destroy", as: :option_value

    resources :properties

    delete '/product_properties/:id', to: "product_properties#destroy", as: :product_property

    resources :orders, except: [:show] do
      member do
        get :cart
        put :advance
        get :confirm
        put :complete
        post :resend
        get "/adjustments/unfinalize", to: "orders#unfinalize_adjustments"
        get "/adjustments/finalize", to: "orders#finalize_adjustments"
        put :approve
        put :cancel
        put :resume
      end

      resource :customer, controller: "orders/customer_details"
      resources :customer_returns, only: [:index, :new, :edit, :create, :update] do
        member do
          put :refund
        end
      end

      resources :adjustments
      resources :return_authorizations do
        member do
          put :fire
        end
      end
      resources :payments, only: [:index, :new, :show, :create] do
        member do
          put :fire
        end

        resources :log_entries
        resources :refunds, only: [:new, :create, :edit, :update]
      end

      resources :reimbursements, only: [:index, :create, :show, :edit, :update] do
        member do
          post :perform
        end
      end

      resources :cancellations, only: [:index] do
        collection do
          post :short_ship
        end
      end
    end

    resource :general_settings, only: :edit
    resources :stores, only: [:index, :new, :create, :edit, :update]

    resources :return_items, only: [:update]

    resources :taxonomies do
      collection do
        post :update_positions
      end
      resources :taxons do
        resource :attachment, controller: 'taxons/attachment', only: [:destroy]
      end
    end

    resources :taxons, only: [:index, :show] do
      collection do
        get :search
      end
    end

    resources :reimbursement_types, only: [:index]
    resources :adjustment_reasons, except: [:show, :destroy]
    resources :refund_reasons, except: [:show, :destroy]
    resources :return_reasons, except: [:show, :destroy]
    resources :store_credit_reasons, except: [:show]

    resources :shipping_methods
    resources :shipping_categories

    resources :stock_locations do
      resources :stock_movements, only: [:index]
      collection do
        post :transfer_stock
        post :update_positions
      end
    end

    resources :stock_items, except: [:show, :new, :edit]
    resources :tax_rates

    resources :payment_methods do
      collection do
        post :update_positions
      end
    end

    resources :users do
      member do
        get :orders
        get :items
        get :addresses
        put :addresses
      end
      resources :store_credits, except: [:destroy] do
        member do
          get :edit_amount
          put :update_amount
          get :edit_validity
          put :invalidate
        end
      end
    end

    resources :style_guide, only: [:index]
  end

  get '/admin', to: 'admin/root#index', as: :admin
end
