# frozen_string_literal: true

module Solidus
  module Api
    class OptionTypesController < Solidus::Api::BaseController
      def index
        if params[:ids]
          @option_types = Solidus::OptionType.includes(:option_values).accessible_by(current_ability, :read).where(id: params[:ids].split(','))
        else
          @option_types = Solidus::OptionType.includes(:option_values).accessible_by(current_ability, :read).load.ransack(params[:q]).result
        end
        respond_with(@option_types)
      end

      def show
        @option_type = Solidus::OptionType.accessible_by(current_ability, :read).find(params[:id])
        respond_with(@option_type)
      end

      def create
        authorize! :create, Solidus::OptionType
        @option_type = Solidus::OptionType.new(option_type_params)
        if @option_type.save
          render :show, status: 201
        else
          invalid_resource!(@option_type)
        end
      end

      def update
        @option_type = Solidus::OptionType.accessible_by(current_ability, :update).find(params[:id])
        if @option_type.update(option_type_params)
          render :show
        else
          invalid_resource!(@option_type)
        end
      end

      def destroy
        @option_type = Solidus::OptionType.accessible_by(current_ability, :destroy).find(params[:id])
        @option_type.destroy
        render plain: nil, status: 204
      end

      private

      def option_type_params
        params.require(:option_type).permit(permitted_option_type_attributes)
      end
    end
  end
end
