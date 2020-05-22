# frozen_string_literal: true

module Spree
  module Core
    module ControllerHelpers
      module CurrentHost
        extend ActiveSupport::Concern

        included do
          before_action do
            ActiveStorage::Current.host = request.base_url
          end
        end
      end
    end
  end
end
