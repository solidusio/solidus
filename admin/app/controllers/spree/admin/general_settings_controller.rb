# frozen_string_literal: true

module Spree
  module Admin
    class GeneralSettingsController < Spree::Admin::BaseController
      def edit
        redirect_to admin_stores_path
      end
    end
  end
end
