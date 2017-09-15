json.store do
  json.extract!(@store, :id, :name, :url, :meta_description, :meta_keywords,
    :seo_title, :mail_from_address, :default_currency, :code, :default)

  json.preferences do
    json.available_locales @store.preferences[:available_locales]
  end
end
