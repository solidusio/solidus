# frozen_string_literal: true

module Spree
  module Admin
    class OrdersController < Spree::Admin::BaseController
      helper 'spree/admin/payments'

      before_action :initialize_order_events
      before_action :load_order, only: [:edit, :update, :complete, :advance, :cancel, :resume, :approve, :resend, :unfinalize_adjustments, :finalize_adjustments, :cart, :confirm]
      around_action :lock_order, only: [:update, :advance, :complete, :confirm, :cancel, :resume, :approve, :resend]

      rescue_from Spree::Order::InsufficientStock, with: :insufficient_stock_error

      respond_to :html

      def index
        params[:q] ||= {}
        params[:q][:completed_at_not_null] ||= '1' if Spree::Config[:show_only_complete_orders_by_default]
        @show_only_completed = params[:q][:completed_at_not_null] == '1'
        params[:q][:s] ||= @show_only_completed ? 'completed_at desc' : 'created_at desc'
        params[:q][:completed_at_not_null] = '' unless @show_only_completed

        # As date params are deleted if @show_only_completed, store
        # the original date so we can restore them into the params
        # after the search
        created_at_gt = params[:q][:created_at_gt]
        created_at_lt = params[:q][:created_at_lt]

        params[:q].delete(:inventory_units_shipment_id_null) if params[:q][:inventory_units_shipment_id_null] == "0"

        if params[:q][:created_at_gt].present?
          params[:q][:created_at_gt] = begin
                                         Time.zone.parse(params[:q][:created_at_gt]).beginning_of_day
                                       rescue StandardError
                                         ""
                                       end
        end

        if params[:q][:created_at_lt].present?
          params[:q][:created_at_lt] = begin
                                         Time.zone.parse(params[:q][:created_at_lt]).end_of_day
                                       rescue StandardError
                                         ""
                                       end
        end

        if @show_only_completed
          params[:q][:completed_at_gt] = params[:q].delete(:created_at_gt)
          params[:q][:completed_at_lt] = params[:q].delete(:created_at_lt)
        end

        @search = Spree::Order.accessible_by(current_ability, :index).ransack(params[:q])
        @orders = @search.result.includes([:user]).
          page(params[:page]).
          per(params[:per_page] || Spree::Config[:orders_per_page])

        # Restore dates
        params[:q][:created_at_gt] = created_at_gt
        params[:q][:created_at_lt] = created_at_lt
      end

      def new
        user = Spree.user_class.find_by(id: params[:user_id]) if params[:user_id]
        @order = Spree::Core::Importer::Order.import(user, order_params)
        redirect_to cart_admin_order_url(@order)
      end

      def edit
        require_ship_address
      end

      def cart
        if @order.shipped_shipments.count > 0
          redirect_to edit_admin_order_url(@order)
        end
      end

      def advance
        if @order.completed?
          flash[:notice] = t('spree.order_already_completed')
          redirect_to edit_admin_order_url(@order)
        else
          @order.contents.advance

          if @order.can_complete?
            flash[:success] = t('spree.order_ready_for_confirm')
          else
            flash[:error] = @order.errors.full_messages
          end
          redirect_to confirm_admin_order_url(@order)
        end
      end

      # GET
      def confirm
        if @order.completed?
          redirect_to edit_admin_order_url(@order)
        elsif !@order.can_complete?
          render template: 'spree/admin/orders/confirm_advance'
        end
      end

      # PUT
      def complete
        @order.complete!
        flash[:success] = t('spree.order_completed')
        redirect_to edit_admin_order_url(@order)
      rescue StateMachines::InvalidTransition => error
        flash[:error] = error.message
        redirect_to confirm_admin_order_url(@order)
      end

      def cancel
        @order.canceled_by(try_spree_current_user)
        flash[:success] = t('spree.order_canceled')
        redirect_to(spree.edit_admin_order_path(@order))
      end

      def resume
        @order.resume!
        flash[:success] = t('spree.order_resumed')
        redirect_to(spree.edit_admin_order_path(@order))
      end

      def approve
        @order.contents.approve(user: try_spree_current_user)
        flash[:success] = t('spree.order_approved')
        redirect_to(spree.edit_admin_order_path(@order))
      end

      def resend
        Spree::Config.order_mailer_class.confirm_email(@order, true).deliver_later
        flash[:success] = t('spree.order_email_resent')

        redirect_to(spree.edit_admin_order_path(@order))
      end

      def unfinalize_adjustments
        adjustments = @order.all_adjustments.finalized
        adjustments.each(&:unfinalize!)
        flash[:success] = t('spree.all_adjustments_unfinalized')

        respond_with(@order) { |format| format.html { redirect_to(spree.admin_order_adjustments_path(@order)) } }
      end

      def finalize_adjustments
        adjustments = @order.all_adjustments.not_finalized
        adjustments.each(&:finalize!)
        flash[:success] = t('spree.all_adjustments_finalized')

        respond_with(@order) { |format| format.html { redirect_to(spree.admin_order_adjustments_path(@order)) } }
      end

      private

      def order_params
        {
          created_by_id: try_spree_current_user.try(:id),
          frontend_viewable: false,
          store_id: current_store.try(:id)
        }.with_indifferent_access
      end

      def load_order
        @order = Spree::Order.includes(:adjustments).find_by!(number: params[:id])
        authorize! action, @order
      end

      # Used for extensions which need to provide their own custom event links on the order details view.
      def initialize_order_events
        @order_events = %w{approve cancel resume}
      end

      def model_class
        Spree::Order
      end

      def insufficient_stock_error
        flash[:error] = t('spree.insufficient_stock_for_order')
        redirect_to cart_admin_order_url(@order)
      end

      def require_ship_address
        if @order.ship_address.nil?
          flash[:notice] = t('spree.fill_in_customer_info')
          redirect_to edit_admin_order_customer_url(@order)
        end
      end
    end
  end
end
