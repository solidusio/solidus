module Spree
  class ApiConfiguration < Preferences::Configuration
    preference :requires_authentication, :boolean, default: true
    preference :use_json_web_tokens, :boolean, default: false
  end
end
