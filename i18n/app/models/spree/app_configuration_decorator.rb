Spree::AppConfiguration.class_eval do
  preference :all_locales, :array, :default => ['en', 'es', 'de', 'pt-BR']
  preference :supported_locales, :array, :default => ['en', 'es', 'de', 'pt-BR']
end
