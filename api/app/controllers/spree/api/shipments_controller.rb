module Spree
  module Api
    class ShipmentsController < Spree::Api::BaseController

      before_filter :find_order, only: [:create, :update, :ready, :ship, :add, :remove]
      before_filter :find_order_on_create, only: :create
      before_filter :find_shipment, only: [:update, :ship, :ready, :add, :remove]
      around_filter :lock_order, only: [:create, :update, :ready, :ship, :add, :remove]
      before_filter :update_shipment, only: [:ship, :ready, :add, :remove]
      before_filter :load_transfer_params, only: [:transfer_to_location, :transfer_to_shipment]

      def mine
        if current_api_user.persisted?
          @shipments = Spree::Shipment
            .reverse_chronological
            .joins(:order)
            .where(spree_orders: {user_id: current_api_user.id})
            .includes(mine_includes)
            .ransack(params[:q]).result.page(params[:page]).per(params[:per_page])
        else
          render "spree/api/errors/unauthorized", status: :unauthorized
        end
      end

      def create
        authorize! :create, Shipment
        variant = Spree::Variant.find(params[:variant_id])
        quantity = params[:quantity].to_i
        @shipment = @order.shipments.create(stock_location_id: params[:stock_location_id])
        @order.contents.add(variant, quantity, nil, @shipment)

        @shipment.refresh_rates
        @shipment.save!

        respond_with(@shipment.reload, default_template: :show)
      end

      def update
        @shipment.update_attributes(shipment_params)

        @shipment.reload
        respond_with(@shipment, default_template: :show)
      end

      def ready
        unless @shipment.ready?
          if @shipment.can_ready?
            @shipment.ready!
          else
            render 'spree/api/shipments/cannot_ready_shipment', status: 422 and return
          end
        end
        respond_with(@shipment, default_template: :show)
      end

      def ship
        unless @shipment.shipped?
          @shipment.ship!
        end
        respond_with(@shipment, default_template: :show)
      end

      def add
        variant = Spree::Variant.find(params[:variant_id])
        quantity = params[:quantity].to_i

        @shipment.order.contents.add(variant, quantity, nil, @shipment)

        respond_with(@shipment, default_template: :show)
      end

      def remove
        variant = Spree::Variant.find(params[:variant_id])
        quantity = params[:quantity].to_i

        @shipment.order.contents.remove(variant, quantity, @shipment)
        @shipment.reload if @shipment.persisted?
        respond_with(@shipment, default_template: :show)
      end

      def transfer_to_location
        @stock_location = Spree::StockLocation.find(params[:stock_location_id])
        @original_shipment.transfer_to_location(@variant, @quantity, @stock_location)
        render json: {success: true, message: Spree.t(:shipment_transfer_success)}, status: 201
      end

      def transfer_to_shipment
        @target_shipment  = Spree::Shipment.find_by!(number: params[:target_shipment_number])
        @original_shipment.transfer_to_shipment(@variant, @quantity, @target_shipment)
        render json: {success: true, message: Spree.t(:shipment_transfer_success)}, status: 201
      end

      private

      def find_order
        if params[:order_id].present?
          ActiveSupport::Deprecation.warn "Spree::Api::ShipmentsController#find_order is deprecated and will be removed from Spree 2.3.x, access shipments directly without being nested to orders route instead.", caller
          @order = Spree::Order.find_by!(number: params[:order_id])
          authorize! :read, @order
        end
      end

      def find_order_on_create
        # TODO Can remove conditional here once deprecated #find_order is removed.
        unless @order.present?
          @order = Spree::Order.find_by!(number: params[:shipment][:order_id])
          authorize! :read, @order
        end
      end

      def find_shipment
        if @order.present?
          @shipment = @order.shipments.accessible_by(current_ability, :update).find_by!(number: params[:id])
        else
          @shipment = Spree::Shipment.accessible_by(current_ability, :update).readonly(false).find_by!(number: params[:id])
          @order = @shipment.order
        end
      end

      def update_shipment
        @shipment.update_attributes(shipment_params)
        @shipment.reload
      end

      def load_transfer_params
        @original_shipment         = Spree::Shipment.where(number: params[:original_shipment_number]).first
        @variant                   = Spree::Variant.find(params[:variant_id])
        @quantity                  = params[:quantity].to_i
        authorize! :read, @original_shipment
        authorize! :create, Shipment
      end

      def shipment_params
        if params[:shipment] && !params[:shipment].empty?
          params.require(:shipment).permit(permitted_shipment_attributes)
        else
          {}
        end
      end

      def mine_includes
        {
          order: {
            bill_address: {
              state: {},
              country: {},
            },
            ship_address: {
              state: {},
              country: {},
            },
            adjustments: {},
            payments: {
              order: {},
              payment_method: {},
            },
          },
          inventory_units: {
            line_item: {
              product: {},
              variant: {},
            },
            variant: {
              product: {},
              default_price: {},
              option_values: {
                option_type: {},
              },
            },
          },
        }
      end
    end
  end
end
