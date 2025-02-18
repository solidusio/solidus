# frozen_string_literal: true

Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :users do
      resource :api_key, controller: "users/api_key", only: [:create, :destroy]
    end
  end

  namespace :api, defaults: {format: "json"} do
    resources :promotions, only: [:show]

    resources :products do
      resources :images
      # TODO: Use shallow option on Solidus v4.0
      resources :variants
      resources :product_properties
    end

    # TODO: Use only: :index on Solidus v4.0
    resources :variants do
      resources :images
    end

    concern :order_routes do
      resources :line_items
      resources :payments do
        member do
          put :authorize
          put :capture
          put :purchase
          put :void
          put :credit
        end
      end

      resources :addresses, only: [:show, :update]

      resources :return_authorizations do
        member do
          put :cancel
        end
      end

      resources :customer_returns, except: :destroy
    end

    resources :checkouts, only: [:update], concerns: :order_routes do
      member do
        put :next
        put :advance
        put :complete
      end
    end

    resources :option_types do
      resources :option_values, shallow: true
    end
    resources :option_values, only: :index

    get "/orders/mine", to: "orders#mine", as: "my_orders"
    get "/orders/current", to: "orders#current", as: "current_order"

    resources :orders, concerns: :order_routes do
      member do
        put :cancel
        put :empty
      end

      resources :coupon_codes, only: [:create, :destroy]
    end

    resources :zones
    resources :countries, only: [:index, :show] do
      resources :states, only: [:index, :show]
    end

    resources :shipments, only: [:create, :update] do
      collection do
        post "transfer_to_location"
        post "transfer_to_shipment"
        get :mine
      end

      member do
        get :estimated_rates
        put :select_shipping_method

        put :ready
        put :ship
        put :add
        put :remove
      end
    end
    resources :states, only: [:index, :show]

    resources :taxonomies do
      resources :taxons
    end

    resources :taxons, only: [:index]

    resources :inventory_units, only: [:show, :update]

    resources :users do
      resources :credit_cards, only: [:index]
      resource :address_book, only: [:show, :update, :destroy]
    end

    resources :credit_cards, only: [:update]

    resources :properties
    resources :stock_locations do
      resources :stock_movements
      resources :stock_items
    end

    resources :stock_items, only: [:index, :update, :destroy]

    resources :stores

    resources :store_credit_events, only: [] do
      collection do
        get :mine
      end
    end

    get "/config/money", to: "config#money"
    get "/config", to: "config#show"
    put "/classifications", to: "classifications#update", as: :classifications
    get "/taxons/products", to: "taxons#products", as: :taxon_products
  end
end
