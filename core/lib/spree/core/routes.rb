module Spree
  module Core
    class Engine < ::Rails::Engine
      def self.add_routes(&block)
        Spree::Deprecation.warn "Spree::Core::Engine.add_routes is deprecated, use Spree::Core::Engine.routes.draw instead"
        routes.draw(&block)
      end

      def self.append_routes(&block)
        Spree::Deprecation.warn "Spree::Core::Engine.append_routes is deprecated, use Spree::Core::Engine.routes.append instead"
        routes.append(&block)
      end

      def self.draw_routes(&block)
        Spree::Deprecation.warn "Spree::Core::Engine.draw_routes is deprecated, use Spree::Core::Engine.routes.draw instead"
        routes.draw(&block)
      end
    end
  end
end
