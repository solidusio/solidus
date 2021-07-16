# frozen_string_literal: true

module Spree
  class OrderContentsController < Spree::StoreController
    before_action :set_order, only: [:create]
    skip_before_action :verify_authenticity_token, only: [:create]

    def create
      authorize! :update, @order, cookies.signed[:guest_token]

      variant = Spree::Variant.find(params[:variant_id])
      quantity = params[:quantity].present? ? params[:quantity].to_i : 1
      add_line_item_to_order(variant, quantity)

      if @order.errors.any?
        flash[:error] = @order.errors.full_messages.join(", ")
        redirect_back_or_default(spree.root_path)
      else
        redirect_to cart_path
      end
    end

    private

    def set_order
      @order = current_order(create_order_if_necessary: true)
    end

    def add_line_item_to_order(variant, quantity)
      if quantity_is_reasonable?(quantity)
        begin
          @order.contents.add(variant, quantity)
        rescue ActiveRecord::RecordInvalid => error
          @order.errors.add(:base, error.record.errors.full_messages.join(", "))
        end
      end
    end

    # 2,147,483,647 is crazy. See issue https://github.com/spree/spree/issues/2695.
    def quantity_is_reasonable?(quantity)
      is_reasonable = quantity.between?(1, 2_147_483_647)
      @order.errors.add(:base, t('spree.please_enter_reasonable_quantity')) unless is_reasonable
      is_reasonable
    end
  end
end
