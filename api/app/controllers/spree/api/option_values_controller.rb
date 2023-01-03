# frozen_string_literal: true

module Spree
  module Api
    class OptionValuesController < Spree::Api::BaseController
      def index
        if params[:ids]
          @option_values = scope.where(id: params[:ids])
        else
          @option_values = scope.ransack(params[:q]).result.distinct
        end
        respond_with(@option_values)
      end

      def show
        warn_if_nested_member_route

        @option_value = scope.find(params[:id])
        respond_with(@option_value)
      end

      def create
        Spree::Deprecation.warn <<~MSG unless request.path.include?('/option_types/')
          This route is deprecated, as it'll be no longer possible to create an
          option_value without an associated option_type. Please, use instead:

            POST api/option_types/{option_type_id}/option_values
        MSG

        authorize! :create, Spree::OptionValue
        @option_value = scope.new(option_value_params)
        if @option_value.save
          render :show, status: 201
        else
          invalid_resource!(@option_value)
        end
      end

      def update
        warn_if_nested_member_route

        @option_value = scope.accessible_by(current_ability, :update).find(params[:id])
        if @option_value.update(option_value_params)
          render :show
        else
          invalid_resource!(@option_value)
        end
      end

      def destroy
        warn_if_nested_member_route

        @option_value = scope.accessible_by(current_ability, :destroy).find(params[:id])
        @option_value.destroy
        render plain: nil, status: 204
      end

      private

      def scope
        if params[:option_type_id]
          @scope ||= Spree::OptionType.find(params[:option_type_id]).option_values.accessible_by(current_ability)
        else
          @scope ||= Spree::OptionValue.accessible_by(current_ability).load
        end
      end

      def option_value_params
        params.require(:option_value).permit(permitted_option_value_attributes)
      end

      def warn_if_nested_member_route
        Spree::Deprecation.warn <<~MSG if request.path.include?('/option_types/')
          This route is deprecated. Use shallow version instead:

            #{request.method.upcase} api/option_values/:id
        MSG
      end
    end
  end
end

