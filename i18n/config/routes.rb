Spree::Core::Engine.routes.prepend do
  match '/locale/set', :to => 'locale#set', :defaults => { :format => :json }, :as => :set_locale

  namespace :admin do
    resources :products do
      resources :translations
    end
  end
end
