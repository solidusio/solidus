module SpreeI18n
  class Configuration < Spree::Preferences::Configuration
    # These configs intend to, respectively:
    #
    #   Set locales that should be available for end users
    #
    preference :available_locales, :array, default: [:en]
  end
end
