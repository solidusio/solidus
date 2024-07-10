# frozen_string_literal: true

SolidusAdmin::Engine.routes.draw do
  require "solidus_admin/admin_resources"
  extend SolidusAdmin::AdminResources

  resource :account, only: :show
  resources :countries, only: [] do
    get 'states', to: 'countries#states'
  end

  admin_resources :products, only: [:index, :update, :destroy] do
    collection do
      put :discontinue
      put :activate
    end
  end

  # Needs a constraint to avoid interpreting "new" as a product's slug
  admin_resources :products, only: [
    :show, :edit
  ], constraints: ->{ SolidusAdmin::Config.enable_alpha_features? && _1.path != "/admin/products/new" }

  admin_resources :orders, only: [:index]

  admin_resources :orders, except: [
    :destroy, :index
  ], constraints: ->{ SolidusAdmin::Config.enable_alpha_features? } do
    resources :adjustments, only: [:index] do
      collection do
        delete :destroy
        put :lock
        put :unlock
      end
    end

    resources :line_items, only: [:destroy, :create, :update]
    resource :customer
    resource :ship_address, only: [:show, :edit, :update], controller: "addresses", type: "ship"
    resource :bill_address, only: [:show, :edit, :update], controller: "addresses", type: "bill"

    member do
      get :variants_for
      get :customers_for
    end
  end

  admin_resources :users, only: [:index, :destroy]
  admin_resources :promotions, only: [:index, :destroy]
  admin_resources :properties, only: [:index, :destroy]
  admin_resources :option_types, only: [:index, :destroy], sortable: true
  admin_resources :taxonomies, only: [:index, :destroy], sortable: true
  admin_resources :promotion_categories, only: [:index, :destroy]
  admin_resources :tax_categories, except: [:show]
  admin_resources :tax_rates, only: [:index, :destroy]
  admin_resources :payment_methods, only: [:index, :destroy], sortable: true
  admin_resources :stock_items, only: [:index, :edit, :update]
  admin_resources :shipping_methods, only: [:index, :destroy]
  admin_resources :shipping_categories, only: [:index, :destroy]
  admin_resources :stock_locations, only: [:index, :destroy]
  admin_resources :stores, only: [:index, :destroy]
  admin_resources :zones, only: [:index, :destroy]
  admin_resources :refund_reasons, only: [:index, :new, :create, :destroy]
  admin_resources :reimbursement_types, only: [:index]
  admin_resources :return_reasons, only: [:index, :new, :create, :destroy]
  admin_resources :adjustment_reasons, only: [:index, :destroy]
  admin_resources :store_credit_reasons, only: [:index, :destroy]
end
