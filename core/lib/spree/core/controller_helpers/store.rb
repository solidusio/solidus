module Spree
  module Core
    module ControllerHelpers
      module Store
        extend ActiveSupport::Concern

        # @!attribute [rw] current_store_class
        #   @!scope class
        #   Extension point for overriding how the current store is chosen.
        #   Defaults to checking headers and server name
        #   @return [#store] class used to help find the current store
        included do
          class_attribute :current_store_class
          self.current_store_class = Spree::Core::CurrentStore

          helper_method :current_store
        end

        def current_store
          @current_store ||= current_store_class.new(request).store
        end
      end
    end
  end
end
