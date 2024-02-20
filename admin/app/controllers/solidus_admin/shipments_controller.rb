# frozen_string_literal: true

class SolidusAdmin::ShipmentsController < SolidusAdmin::BaseController
  include Spree::Core::ControllerHelpers::StrongParameters

  before_action :load_order, :load_shipment, only: [:edit, :update, :split_edit, :split_create]
  before_action :load_shipment, only: [:split_edit, :split_create]
  before_action :load_split_variants, only: [:split_create]
  #before_action :load_transfer_params, only: [:split_create]

  def edit
    render component('orders/show/shipment/edit').new(shipment: @shipment)
  end

  def split_edit
    render component('orders/show/shipment/split').new(shipment: @shipment)

    # if params[:stock_location_id]
    #   @desired_stock_location = Spree::StockLocation.find(params[:stock_location_id])
    #   @desired_shipment = @original_shipment.order.shipments.build(stock_location: @desired_stock_location)
    # end
    #
    # @desired_shipment ||= Spree::Shipment.find_by!(number: params[:target_shipment_number])
    #
    # fulfilment_changer = Spree::FulfilmentChanger.new(
    #   current_shipment: @original_shipment,
    #   desired_shipment: @desired_shipment,
    #   variant: @variant,
    #   quantity: @quantity,
    #   track_inventory: Spree::Config.track_inventory_levels
    # )
    #
    # if fulfilment_changer.run!
    #   redirect_to order_path(@order), status: :see_other, notice: t('.success')
    # else
    #   flash.now[:error] = @shipment.errors[:base].join(", ") if @shipment.errors[:base].any?
    #
    #   respond_to do |format|
    #     format.html do
    #       render component('orders/show/shipment/split').new(shipment: @shipment), status: :unprocessable_entity
    #     end
    #   end
    # end
  end

  def split_create
    @desired_shipment = @shipment.order.shipments.build(stock_location: @shipment.stock_location)

    ActiveRecord::Base.transaction do
      results = @variants_with_quantity.map do |variant, quantity|
        fulfilment_changer = Spree::FulfilmentChanger.new(
          current_shipment: @shipment,
          desired_shipment: @desired_shipment,
          variant: variant,
          quantity: quantity,
          track_inventory: Spree::Config.track_inventory_levels
        )
        fulfilment_changer.run!
      end
      raise(ActiveRecord::Rollback) if results.include?(false)

      if results.all?(true)
        redirect_to order_path(@order), status: :see_other, notice: t('.success')
      else
        render json: { success: false, message: fulfilment_changer.errors.full_messages.to_sentence }, status: :accepted
      end
    end
  end

  def update
    if @shipment.update_attributes_and_order(shipment_params)
      redirect_to order_path(@order), status: :see_other, notice: t('.success')
    else
      flash.now[:error] = @shipment.errors[:base].join(", ") if @shipment.errors[:base].any?

      respond_to do |format|
        format.html do
          render component('orders/show/shipment/edit').new(shipment: @shipment), status: :unprocessable_entity
        end
      end
    end
  end

  private

  def load_order
    @order = Spree::Order.find_by!(number: params[:order_id])
  end

  def load_shipment
    @shipment = @order.shipments.find_by!(number: params[:id])
  end

  # def load_transfer_params
  #   @original_shipment         = Spree::Shipment.find_by!(number: params[:original_shipment_number])
  #   @order                     = @original_shipment.order
  #   @variant                   = Spree::Variant.find(params[:variant_id])
  #   @quantity                  = params[:quantity].to_i
  #   authorize! [:update, :destroy], @original_shipment
  #   authorize! :create, Shipment
  # end

  def load_split_variants
    params[:variants].permit!
    @variants_with_quantity = {}
    params[:variants].each do |variant_id, qty|
      @variants_with_quantity[Spree::Variant.find(variant_id)] = qty[:quantity].to_i
    end
  end

  def shipment_params
    if params[:shipment] && !params[:shipment].empty?
      params.require(:shipment).permit(permitted_shipment_attributes)
    else
      {}
    end
  end

  def authorization_subject
    @order || Spree::Order
  end
end
