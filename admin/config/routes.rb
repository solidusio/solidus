# frozen_string_literal: true

SolidusAdmin::Engine.routes.draw do
  resource :account, only: :show

  resources(
    :products,
    only: [:index, :show, :edit, :update],
    constraints: ->{ _1.path != "/admin/products/new" },
  ) do
    collection do
      delete :destroy
      put :discontinue
      put :activate
    end
  end

  resources :countries, only: [] do
    get 'states', to: 'countries#states'
  end

  resources :orders, except: [:destroy] do
    resources :line_items, only: [:destroy, :create, :update]
    resource :customer
    resource :ship_address, only: [:show, :edit, :update], controller: "addresses", type: "ship"
    resource :bill_address, only: [:show, :edit, :update], controller: "addresses", type: "bill"

    member do
      get :variants_for
      get :customers_for
    end
  end

  resources :users, only: [:index] do
    collection do
      delete :destroy
    end
  end

  resources :promotions, only: [:index] do
    collection do
      delete :destroy
    end
  end

  resources :tax_categories, only: [:index] do
    collection do
      delete :destroy
    end
  end
end
