Spree::Core::Engine.routes.draw do
  # from routing-filter gem
  filter :locale

  post '/locale/set', to: 'locale#set', defaults: { format: :json }, as: :set_locale
end
