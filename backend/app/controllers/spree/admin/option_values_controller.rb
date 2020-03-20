# frozen_string_literal: true

module Spree
  module Admin
    class OptionValuesController < Spree::Admin::BaseController
      def destroy
        option_value = Spree::OptionValue.find(params[:id])
        option_value.destroy
        flash[:success] = flash_message_for(option_value, :successfully_removed)
        render partial: "spree/admin/shared/destroy"
      end
    end
  end
end
