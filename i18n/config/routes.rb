Spree::Core::Engine.add_routes do
  # from routing-filter gem
  filter :locale

  post '/locale/set', to: 'locale#set', defaults: { format: :json }, as: :set_locale

  namespace :admin do
    get '/:resource/:resource_id/translations' => 'translations#index', as: :translations
    patch '/option_values/:id' => 'option_values#update', as: :option_type_option_value
    patch 'product/:id/product_properties/:id' => "product_properties#translate", as: :translate_product_property
  end
end
