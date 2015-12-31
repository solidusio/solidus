module Solidus
  module Admin
    class OptionValuesController < Solidus::Admin::BaseController
      def destroy
        option_value = Solidus::OptionValue.find(params[:id])
        option_value.destroy
        render :text => nil
      end
    end
  end
end
