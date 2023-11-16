# frozen_string_literal: true

module Spree
  module Admin
    class DashboardsController < BaseController
      before_action :deprecate
      def deprecate
        Spree.deprecator.warn "The #{self.class.name} is deprecated. If you still use dashboards, please copy all controllers and views from solidus_backend to your application."
      end
    end
  end
end
