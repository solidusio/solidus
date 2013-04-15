Spree::Core::Engine.routes.prepend do
  namespace :admin do
    resources :products do
      resources :translations
    end
  end
end
