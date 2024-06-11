# frozen_string_literal: true

module SolidusAdmin
  class LineItemsController < SolidusAdmin::BaseController
    def destroy
      load_order
      load_line_item

      @line_item.destroy!

      redirect_to order_path(@order), status: :see_other, notice: t('.success')
    end

    def create
      load_order
      variant_id = params.require(:line_item).require(:variant_id)
      @variant = Spree::Variant.find(variant_id)
      @line_item = @order.contents.add(@variant)

      redirect_to order_path(@order), status: :see_other, notice: t('.success')
    end

    def update
      load_order
      load_line_item

      desired_quantity = params[:line_item][:quantity].to_i

      @line_item = @order.contents.add(@line_item.variant, desired_quantity - @line_item.quantity)

      redirect_to order_path(@order), status: :see_other, notice: t('.success')
    end

    private

    def load_order
      @order = Spree::Order.find_by!(number: params[:order_id])
      authorize! action_name, @order
    end

    def load_line_item
      @line_item = @order.line_items.find(params[:id])
    end
  end
end
