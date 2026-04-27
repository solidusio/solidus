# frozen_string_literal: true

class CheckoutBaseController < StoreController
  before_action :load_order
  around_action :lock_order

  before_action :ensure_order_is_not_skipping_states
  before_action :ensure_order_not_completed
  before_action :ensure_checkout_allowed
  before_action :ensure_sufficient_stock_lines

  before_action :check_authorization

  helper 'orders', 'spree/checkout'

  rescue_from Spree::Core::GatewayError, with: :rescue_from_spree_gateway_error
  rescue_from Spree::Order::InsufficientStock, with: :insufficient_stock_error

  private

  def load_order
    @order = current_order
    redirect_to(cart_path) && return unless @order
  end

  # Allow the customer to only go back or stay on the current state
  # when trying to change it via params[:state]. It's not allowed to
  # jump forward and skip states (unless #skip_state_validation? is
  # truthy).
  def ensure_order_is_not_skipping_states
    if params[:state]
      redirect_to checkout_state_path(@order.state) if @order.can_go_to_state?(params[:state]) && !skip_state_validation?
      @order.state = params[:state]
    end
  end

  def ensure_checkout_allowed
    unless @order.checkout_allowed?
      redirect_to cart_path
    end
  end

  def ensure_order_not_completed
    redirect_to cart_path if @order.completed?
  end

  def ensure_sufficient_stock_lines
    if @order.insufficient_stock_lines.present?
      out_of_stock_items = @order.insufficient_stock_lines.collect(&:name).to_sentence
      flash[:error] = t('spree.inventory_error_flash_for_insufficient_quantity', names: out_of_stock_items)
      redirect_to cart_path
    end
  end

  def rescue_from_spree_gateway_error(exception)
    flash.now[:error] = t('spree.spree_gateway_error_flash_for_checkout')
    @order.errors.add(:base, exception.message)
    render :edit
  end

  def insufficient_stock_error
    packages = @order.shipments.map(&:to_package)
    if packages.empty?
      flash[:error] = I18n.t('spree.insufficient_stock_for_order')
      redirect_to cart_path
    else
      availability_validator = Spree::Stock::AvailabilityValidator.new
      unavailable_items = @order.line_items.reject { |line_item| availability_validator.validate(line_item) }
      if unavailable_items.any?
        item_names = unavailable_items.map(&:name).to_sentence
        flash[:error] = t('spree.inventory_error_flash_for_insufficient_shipment_quantity', unavailable_items: item_names)
        @order.restart_checkout_flow
        redirect_to checkout_state_path(@order.state)
      end
    end
  end

  def check_authorization
    authorize!(:edit, current_order, cookies.signed[:guest_token])
  end
end
