# frozen_string_literal: true

module Spree
  module Api
    class ShipmentsController < Spree::Api::BaseController
      before_action :find_order_on_create, only: :create
      before_action :find_shipment, only: [:update, :ship, :ready, :add, :remove, :estimated_rates, :select_shipping_method]
      before_action :load_transfer_params, only: [:transfer_to_location, :transfer_to_shipment]
      around_action :lock_order, except: [:mine, :estimated_rates]
      before_action :update_shipment, only: [:ship, :ready, :add, :remove]

      def mine
        if current_api_user
          @shipments = Spree::Shipment
            .reverse_chronological
            .joins(:order)
            .where(spree_orders: { user_id: current_api_user.id })
            .includes(mine_includes)
            .ransack(params[:q]).result

          @shipments = paginate(@shipments)
        else
          render "spree/api/errors/unauthorized", status: :unauthorized
        end
      end

      def estimated_rates
        authorize! :update, @shipment
        estimator = Spree::Config.stock.estimator_class.new
        @shipping_rates = estimator.shipping_rates(@shipment.to_package, false)
      end

      def select_shipping_method
        authorize! :update, @shipment
        shipping_method = Spree::ShippingMethod.find(params.require(:shipping_method_id))
        @shipment.select_shipping_method(shipping_method)
        @order.recalculate
        respond_with(@shipment, default_template: :show)
      end

      def create
        authorize! :create, Shipment
        quantity = params[:quantity].to_i
        @shipment = @order.shipments.create(stock_location_id: params.fetch(:stock_location_id))
        @order.contents.add(variant, quantity, { shipment: @shipment })

        @shipment.save!

        respond_with(@shipment.reload, default_template: :show)
      end

      def update
        @shipment.update_attributes_and_order(shipment_params)

        respond_with(@shipment.reload, default_template: :show)
      end

      def ready
        unless @shipment.ready?
          if @shipment.can_ready?
            @shipment.ready!
          else
            logger.error("cannot_ready_shipment shipment_state=#{@shipment.state}")
            render('spree/api/shipments/cannot_ready_shipment', status: 422) && return
          end
        end
        respond_with(@shipment, default_template: :show)
      end

      def ship
        authorize! :ship, @shipment
        unless @shipment.shipped?
          @shipment.suppress_mailer = (params[:send_mailer] == 'false')
          @shipment.ship!
        end
        respond_with(@shipment, default_template: :show)
      end

      def add
        quantity = params[:quantity].to_i

        @shipment.order.contents.add(variant, quantity, { shipment: @shipment })
        respond_with(@shipment, default_template: :show)
      end

      def remove
        quantity = params[:quantity].to_i

        if @shipment.shipped? || @shipment.canceled?
          @shipment.errors.add(:base, :cannot_remove_items_shipment_state, state: @shipment.state)
          invalid_resource!(@shipment)
        else
          @shipment.order.contents.remove(variant, quantity, { shipment: @shipment })
          @shipment.reload if @shipment.persisted?
          respond_with(@shipment, default_template: :show)
        end
      end

      def transfer_to_location
        @desired_stock_location = Spree::StockLocation.find(params[:stock_location_id])
        @desired_shipment = @original_shipment.order.shipments.build(stock_location: @desired_stock_location)
        transfer_to_shipment
      end

      def transfer_to_shipment
        @desired_shipment ||= Spree::Shipment.find_by!(number: params[:target_shipment_number])

        fulfilment_changer = Spree::FulfilmentChanger.new(
          current_shipment: @original_shipment,
          desired_shipment: @desired_shipment,
          variant: @variant,
          quantity: @quantity
        )

        if fulfilment_changer.run!
          render json: { success: true, message: t('spree.api.shipment.transfer_success') }, status: :accepted
        else
          render json: { success: false, message: fulfilment_changer.errors.full_messages.to_sentence }, status: :accepted
        end
      end

      private

      def load_transfer_params
        @original_shipment         = Spree::Shipment.find_by!(number: params[:original_shipment_number])
        @order                     = @original_shipment.order
        @variant                   = Spree::Variant.find(params[:variant_id])
        @quantity                  = params[:quantity].to_i
        authorize! [:update, :destroy], @original_shipment
        authorize! :create, Shipment
      end

      def find_order_on_create
        @order = Spree::Order.find_by!(number: params[:shipment][:order_id])
        authorize! :read, @order
      end

      def find_shipment
        if @order.present?
          @shipment = @order.shipments.find_by!(number: params[:id])
        else
          @shipment = Spree::Shipment.readonly(false).find_by!(number: params[:id])
          @order = @shipment.order
        end
        authorize! :update, @shipment
      end

      def update_shipment
        @shipment.update(shipment_params)
        @shipment.reload
      end

      def shipment_params
        if params[:shipment] && !params[:shipment].empty?
          params.require(:shipment).permit(permitted_shipment_attributes)
        else
          {}
        end
      end

      def variant
        @variant ||= Spree::Variant.unscoped.find(params.fetch(:variant_id))
      end

      def mine_includes
        {
          order: {
            bill_address: {
              state: {},
              country: {}
            },
            ship_address: {
              state: {},
              country: {}
            },
            adjustments: {},
            payments: {
              order: {},
              payment_method: {}
            }
          },
          inventory_units: {
            line_item: {
              product: {},
              variant: {}
            },
            variant: {
              product: {},
              default_price: {},
              option_values: {
                option_type: {}
              }
            }
          }
        }
      end
    end
  end
end
