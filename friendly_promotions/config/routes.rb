# frozen_string_literal: true

SolidusFriendlyPromotions::Engine.routes.draw do
  namespace :admin do
    resources :promotions, only: [:index, :new]
  end
end
