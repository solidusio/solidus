# frozen_string_literal: true

module Spree
  module Core
    module ControllerHelpers
      module CurrentHost
        extend ActiveSupport::Concern

        included do
          Spree::Deprecation.warn <<~MSG
            'Spree::Core::ControllerHelpers::CurrentHost' is deprecated.
            Please, include 'ActiveStorage::SetCurrent' instead.
          MSG
          include ActiveStorage::SetCurrent
        end
      end
    end
  end
end
