module Solidus
  class ApiConfiguration < Preferences::Configuration
    preference :requires_authentication, :boolean, :default => true
  end
end
