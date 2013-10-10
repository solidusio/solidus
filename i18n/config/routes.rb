Spree::Core::Engine.routes.draw do
  post '/locale/set', :to => 'locale#set', :defaults => { :format => :json }, :as => :set_locale

  namespace :admin do
    get '/:resource/:resource_id/translations' => 'translations#index', as: :translations
    patch '/option_values/:id' => 'option_values#update', as: :option_type_option_value
  end
end
