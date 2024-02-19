# frozen_string_literal: true

class SolidusAdmin::ShipmentsController < SolidusAdmin::BaseController
  include Spree::Core::ControllerHelpers::StrongParameters

  before_action :load_order, :load_shipment, only: [:show, :update]

  def show
    render component('orders/show/shipment/edit').new(shipment: @shipment)
  end

  def update
    if @shipment.update_attributes_and_order(shipment_params)
      redirect_to order_path(@order), status: :see_other, notice: t('.success')
    else
      flash.now[:error] = @order.errors[:base].join(", ") if @order.errors[:base].any?

      respond_to do |format|
        format.html do
          render component('orders/show/shipment/edit').new(order: @order), status: :unprocessable_entity
        end
      end
    end
  end

  private

  def load_order
    @order = Spree::Order.find_by!(number: params[:order_id])
  end

  def load_shipment
    @shipment = @order.shipments.find_by(id: params[:shipment_id])
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
