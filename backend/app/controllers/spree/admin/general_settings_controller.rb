# frozen_string_literal: true

module Solidus
  module Admin
    class GeneralSettingsController < Solidus::Admin::BaseController
      def edit
        redirect_to admin_stores_path
      end
    end
  end
end
