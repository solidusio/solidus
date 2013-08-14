Spree::Core::Engine.routes.draw do
  post '/locale/set', :to => 'locale#set', :defaults => { :format => :json }, :as => :set_locale

  namespace :admin do
    get '/:resource/:resource_id/translations' => 'translations#index', as: :translations
  end
end
