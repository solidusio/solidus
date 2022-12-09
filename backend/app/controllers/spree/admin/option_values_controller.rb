# frozen_string_literal: true

module Spree
  module Admin
    class OptionValuesController < Spree::Admin::BaseController
      def index
        format.json do
          @option_values = if params[:ids]
              scope.where(id: params[:ids])
            else
              scope.ransack(params[:q]).result.distinct
            end

          respond_with(@option_values)
        end
      end

      def destroy
        option_value = Spree::OptionValue.find(params[:id])
        option_value.destroy
        render plain: nil
      end

      private

      def scope
        if params[:option_type_id]
          @scope ||= Spree::OptionType.find(params[:option_type_id]).option_values.accessible_by(current_ability)
        else
          @scope ||= Spree::OptionValue.accessible_by(current_ability).load
        end
      end
    end
  end
end
