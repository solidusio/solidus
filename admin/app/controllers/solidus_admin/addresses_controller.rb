# frozen_string_literal: true

module SolidusAdmin
  class AddressesController < BaseController
    include Spree::Core::ControllerHelpers::StrongParameters

    before_action :load_order, :load_address
    before_action :validate_address_type

    def show
      respond_to do |format|
        format.html do
          render component('orders/show/address').new(
            order: @order,
            user: @order.user,
            address: @address,
            type: address_type,
          )
        end
      end
    end

    def edit
      redirect_to action: :show
    end

    def update
      if @order.contents.update_cart(order_params)
        redirect_to order_path(@order), status: :see_other, notice: t('.success')
      else
        flash.now[:error] = @order.errors[:base].join(", ") if @order.errors[:base].any?

        respond_to do |format|
          format.html do
            render component('orders/show/address').new(
              order: @order,
              user: @order.user,
              address: @order.send("#{address_type}_address"),
              type: address_type,
              status: :unprocessable_entity,
            )
          end
        end
      end
    end

    private

    def load_address
      if params[:address_id].present? && @order.user
        @address =
          @order.user.addresses.find_by(id: params[:address_id]) ||
          @order.user.addresses.build(country: default_country)
      else
        @address =
          @order.public_send("#{address_type}_address") ||
          @order.public_send("build_#{address_type}_address", country: default_country)
      end
    end

    def address_type
      params[:type].presence_in(%w[bill ship])
    end

    def validate_address_type
      unless address_type
        flash[:error] = t('.errors.address_type_invalid')
        redirect_to spree.admin_order_url(@order)
      end
    end

    def default_country
      @default_country ||= begin
        country = Spree::Country.default
        country if Spree::Country.available.exists?(id: country.id)
      end
    end

    def load_order
      @order = Spree::Order.find_by!(number: params[:order_id])
      authorize! action_name, @order
    end

    def order_params
      params.require(:order).permit(
        :use_billing,
        :use_shipping,
        bill_address_attributes: permitted_address_attributes,
        ship_address_attributes: permitted_address_attributes
      )
    end
  end
end
