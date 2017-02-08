Spree::Core::Engine.routes.draw do
  # from routing-filter gem
  filter :locale

  post '/locale/set', to: 'locale#set', defaults: { format: :json }, as: :set_locale

  namespace :admin do
    resource :locale, only: [:show, :update]
  end
end
