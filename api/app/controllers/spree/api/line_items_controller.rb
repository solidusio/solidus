# frozen_string_literal: true

module Spree
  module Api
    class LineItemsController < Spree::Api::BaseController
      before_action :load_order, only: [:create, :update, :destroy]
      around_action :lock_order, only: [:create, :update, :destroy]

      def new
      end

      def create
        variant = Spree::Variant.find(params[:line_item][:variant_id])
        begin
          @line_item = @order.contents.add(
            variant,
            params[:line_item][:quantity] || 1,
            options: line_item_params[:options].to_h,
            **extract_metadata
          )

          respond_with(@line_item, status: 201, default_template: :show)
        rescue ActiveRecord::RecordInvalid => error
          invalid_resource!(error.record)
        end
      end

      def update
        @line_item = find_line_item
        if @order.contents.update_cart(line_items_attributes)
          @line_item.reload
          respond_with(@line_item, default_template: :show)
        else
          invalid_resource!(@line_item)
        end
      end

      def destroy
        @line_item = find_line_item
        @order.contents.remove_line_item(@line_item)
        respond_with(@line_item, status: 204)
      end

      private

      def load_order
        @order ||= Spree::Order.includes(:line_items).find_by!(number: order_id)
        authorize! :update, @order, order_token
      end

      def find_line_item
        id = params[:id].to_i
        @order.line_items.detect { |line_item| line_item.id == id } ||
          raise(ActiveRecord::RecordNotFound)
      end

      def line_items_attributes
        { line_items_attributes: {
            id: params[:id],
            quantity: params[:line_item][:quantity],
            options: line_item_params[:options] || {},
            **extract_metadata
        } }
      end

      def extract_metadata
        metadata = { customer_metadata: line_item_params[:customer_metadata] }

        if current_user_roles&.include?("admin")
          metadata[:admin_metadata] = line_item_params[:admin_metadata]
        end

        metadata
      end

      def line_item_params
        params.require(:line_item).permit(permitted_line_item_attributes)
      end
    end
  end
end
