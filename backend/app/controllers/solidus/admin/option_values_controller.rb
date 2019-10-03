# frozen_string_literal: true

module Solidus
  module Admin
    class OptionValuesController < Solidus::Admin::BaseController
      def destroy
        option_value = Solidus::OptionValue.find(params[:id])
        option_value.destroy
        render plain: nil
      end
    end
  end
end
