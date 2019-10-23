# frozen_string_literal: true

module Spree
  class OrdersController < Spree::StoreController
    helper 'spree/products', 'spree/orders'

    respond_to :html

    before_action :store_guest_token
    before_action :assign_order, only: :update
    # note: do not lock the #edit action because that's where we redirect when we fail to acquire a lock
    around_action :lock_order, only: :update
    before_action :apply_coupon_code, only: :update
    skip_before_action :verify_authenticity_token, only: [:populate]

    def show
      @order = Spree::Order.find_by!(number: params[:id])
      authorize! :read, @order, cookies.signed[:guest_token]
    end

    def update
      authorize! :update, @order, cookies.signed[:guest_token]
      if @order.contents.update_cart(order_params)
        @order.next if params.key?(:checkout) && @order.cart?

        respond_with(@order) do |format|
          format.html do
            if params.key?(:checkout)
              redirect_to checkout_state_path(@order.checkout_steps.first)
            else
              redirect_to cart_path
            end
          end
        end
      else
        respond_with(@order)
      end
    end

    # Shows the current incomplete order from the session
    def edit
      @order = current_order || Spree::Order.incomplete.find_or_initialize_by(guest_token: cookies.signed[:guest_token])
      authorize! :read, @order, cookies.signed[:guest_token]
      associate_user
      if params[:id] && @order.number != params[:id]
        flash[:error] = t('spree.cannot_edit_orders')
        redirect_to cart_path
      end
    end

    # Adds a new item to the order (creating a new order if none already exists)
    def populate
      @order = current_order(create_order_if_necessary: true)
      authorize! :update, @order, cookies.signed[:guest_token]

      variant  = Spree::Variant.find(params[:variant_id])
      quantity = params[:quantity].present? ? params[:quantity].to_i : 1

      # 2,147,483,647 is crazy. See issue https://github.com/spree/spree/issues/2695.
      if !quantity.between?(1, 2_147_483_647)
        @order.errors.add(:base, t('spree.please_enter_reasonable_quantity'))
      end

      begin
        @line_item = @order.contents.add(variant, quantity)
      rescue ActiveRecord::RecordInvalid => error
        @order.errors.add(:base, error.record.errors.full_messages.join(", "))
      end

      respond_with(@order) do |format|
        format.html do
          if @order.errors.any?
            flash[:error] = @order.errors.full_messages.join(", ")
            redirect_back_or_default(spree.root_path)
            return
          else
            redirect_to cart_path
          end
        end
      end
    end

    def populate_redirect
      flash[:error] = t('spree.populate_get_error')
      redirect_to spree.cart_path
    end

    def empty
      if @order = current_order
        authorize! :update, @order, cookies.signed[:guest_token]
        @order.empty!
      end

      redirect_to spree.cart_path
    end

    def accurate_title
      if @order && @order.completed?
        t('spree.order_number', number: @order.number)
      else
        t('spree.shopping_cart')
      end
    end

    private

    def store_guest_token
      cookies.permanent.signed[:guest_token] = params[:token] if params[:token]
    end

    def order_params
      if params[:order]
        params[:order].permit(*permitted_order_attributes)
      else
        {}
      end
    end

    def assign_order
      @order = current_order
      unless @order
        flash[:error] = t('spree.order_not_found')
        redirect_to(root_path) && return
      end
    end

    def apply_coupon_code
      if order_params[:coupon_code].present?
        Spree::Deprecation.warn('This endpoint is deprecated. Please use `Spree::CouponCodesController#create` endpoint instead.')
        @order.coupon_code = order_params[:coupon_code]

        handler = PromotionHandler::Coupon.new(@order).apply

        if handler.error.present?
          flash.now[:error] = handler.error
          respond_with(@order) { |format| format.html { render :edit } } && return
        elsif handler.success
          flash[:success] = handler.success
        end
      end
    end
  end
end
