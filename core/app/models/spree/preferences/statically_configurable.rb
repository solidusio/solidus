module Spree
  module Preferences
    module StaticallyConfigurable
      extend ActiveSupport::Concern

      class_methods do
        def preference_sources
          Spree::Config.static_model_preferences.for_class(self)
        end

        def available_preference_sources
          preference_sources.keys
        end
      end

      # override assignment to cast empty string to nil
      def preference_source=(val)
        super(val.presence)
      end

      def preferences
        if preference_source.present?
          self.class.preference_sources[preference_source] || {}
        else
          super
        end
      end

      def preferences=(val)
        if preference_source
        else
          super
        end
      end
    end
  end
end
