module Spree
  module Core
    Engine.config.to_prepare do
      methods_included = Spree.user_class.included_modules.include? UserMethods

      if !methods_included
        ActiveSupport::Deprecation.warn "#{ Spree.user_class.name } must include Spree::UserMethods"
        Spree.user_class.class_eval { include UserMethods }
      end
    end
  end
end
