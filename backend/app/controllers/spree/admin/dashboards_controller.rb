# frozen_string_literal: true

module Spree
  module Admin
    class DashboardsController < BaseController
      class << self
         Spree.deprecator.warn "The Dashboards controller is deprecated. Please use the new admin dashboard."
      end
    end
  end
end
