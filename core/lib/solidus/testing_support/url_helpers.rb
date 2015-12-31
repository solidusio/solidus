module Spree
  module TestingSupport
    module UrlHelpers
      def solidus
        Solidus::Core::Engine.routes.url_helpers
      end
    end
  end
end
