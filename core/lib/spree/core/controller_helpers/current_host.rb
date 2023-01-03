# frozen_string_literal: true

module Spree
  module Core
    module ControllerHelpers
      module CurrentHost
        extend ActiveSupport::Concern

        included do
          Spree::RailsCompatibility.active_storage_set_current(self)
        end
      end
    end
  end
end

