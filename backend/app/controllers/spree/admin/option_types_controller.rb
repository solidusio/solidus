# frozen_string_literal: true

module Spree
  module Admin
    class OptionTypesController < ResourceController
      before_action :setup_new_option_value, only: :edit

      def update_values_positions
        params[:positions].each do |id, index|
          Spree::OptionValue.where(id: id).update_all(position: index)
        end

        respond_to do |format|
          format.js { head :no_content }
        end
      end

      private

      def location_after_save
        edit_admin_option_type_url(@option_type)
      end

      def load_product
        @product = Spree::Product.find_by_param!(params[:product_id])
      end

      def setup_new_option_value
        @option_type.option_values.build if @option_type.option_values.empty?
      end

      def set_available_option_types
        @available_option_types = if @product.option_type_ids.any?
          Spree::OptionType.where('id NOT IN (?)', @product.option_type_ids)
        else
          Spree::OptionType.all
        end
      end
    end
  end
end
