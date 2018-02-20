# frozen_string_literal: true

module Spree
  module Core
    module ControllerHelpers
      module Store
        extend ActiveSupport::Concern

        included do
          helper_method :current_store
        end

        def current_store
          @current_store ||= Spree::Config.current_store_selector_class.new(request).store
        end
      end
    end
  end
end
