# frozen_string_literal: true

module Spree
  module Admin
    class DashboardsController < BaseController
      class << self
        ActiveSupport::Deprecation.warn(
          "The Dashboard controller is deprecated." \
          "Please update your source code."
        )
      end
    end
  end
end
