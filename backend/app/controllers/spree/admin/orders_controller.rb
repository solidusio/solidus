module Spree
  module Admin
    class OrdersController < Spree::Admin::BaseController
      before_filter :initialize_order_events
      before_filter :load_order, :only => [:edit, :update, :advance, :complete, :confirm, :cancel, :resume, :approve, :resend, :open_adjustments, :close_adjustments, :cart]

      rescue_from Spree::LineItem::InsufficientStock, with: :insufficient_stock_error

      respond_to :html

      def index
        query_present = params[:q]
        params[:q] ||= {}
        params[:q][:completed_at_not_null] ||= '1' if Spree::Config[:show_only_complete_orders_by_default]
        @show_only_completed = params[:q][:completed_at_not_null] == '1'
        params[:q][:s] ||= @show_only_completed ? 'completed_at desc' : 'created_at desc'

        # As date params are deleted if @show_only_completed, store
        # the original date so we can restore them into the params
        # after the search
        created_at_gt = params[:q][:created_at_gt]
        created_at_lt = params[:q][:created_at_lt]

        params[:q].delete(:inventory_units_shipment_id_null) if params[:q][:inventory_units_shipment_id_null] == "0"

        if !params[:q][:created_at_gt].blank?
          params[:q][:created_at_gt] = Time.zone.parse(params[:q][:created_at_gt]).beginning_of_day rescue ""
        end

        if !params[:q][:created_at_lt].blank?
          params[:q][:created_at_lt] = Time.zone.parse(params[:q][:created_at_lt]).end_of_day rescue ""
        end

        if @show_only_completed
          params[:q][:completed_at_gt] = params[:q].delete(:created_at_gt)
          params[:q][:completed_at_lt] = params[:q].delete(:created_at_lt)
        end

        @search = Order.accessible_by(current_ability, :index).ransack(params[:q])

        # lazyoading other models here (via includes) may result in an invalid query
        # e.g. SELECT  DISTINCT DISTINCT "spree_orders".id, "spree_orders"."created_at" AS alias_0 FROM "spree_orders"
        # see https://github.com/spree/spree/pull/3919
        @orders = if query_present
          @search.result(distinct: true)
        else
          @search.result
        end

        @orders = @orders.
          page(params[:page]).
          per(params[:per_page] || Spree::Config[:orders_per_page])

        # Restore dates
        params[:q][:created_at_gt] = created_at_gt
        params[:q][:created_at_lt] = created_at_lt
      end

      def new
        user = Spree.user_class.find_by_id(params[:user_id])
        @order = Spree::Core::Importer::Order.import(user, order_params)
        redirect_to cart_admin_order_url(@order)
      end

      def edit
        can_not_transition_without_customer_info

        unless @order.completed?
          @order.refresh_shipment_rates
        end
      end

      def cart
        unless @order.completed?
          @order.refresh_shipment_rates
        end
        if @order.shipped_shipments.count > 0
          redirect_to edit_admin_order_url(@order)
        end
      end

      def update
        @order.contents.update_cart(params[:order])
        @order.errors.add(:line_items, Spree.t('errors.messages.blank')) if @order.line_items.empty?
        if @order.completed?
          render :action => :edit
        else
          redirect_to admin_order_customer_path(@order)
        end
      end

      def advance
        if @order.completed?
          flash[:notice] = Spree.t('order_already_completed')
          redirect_to edit_admin_order_url(@order)
        else
          @order.contents.advance

          if @order.confirm?
            flash[:success] = Spree.t('order_ready_for_confirm')
            redirect_to confirm_admin_order_url(@order)
          else
            flash[:error] = @order.errors.full_messages
            redirect_to confirm_admin_order_url(@order)
          end
        end
      end

      # GET
      def confirm
        if @order.completed?
          redirect_to edit_admin_order_url(@order)
        elsif !@order.confirm?
          render template: 'spree/admin/orders/confirm_advance'
        end
      end

      # PUT
      def complete
        @order.complete!
        flash[:success] = Spree.t(:order_completed)
        redirect_to edit_admin_order_url(@order)
      rescue StateMachine::InvalidTransition => e
        flash[:error] = e.message
        redirect_to confirm_admin_order_url(@order)
      end

      def cancel
        @order.contents.cancel
        flash[:success] = Spree.t(:order_canceled)
        redirect_to :back
      end

      def resume
        @order.resume!
        flash[:success] = Spree.t(:order_resumed)
        redirect_to :back
      end

      def approve
        @order.contents.approve(user: try_spree_current_user)
        flash[:success] = Spree.t(:order_approved)
        redirect_to :back
      end

      def resend
        OrderMailer.confirm_email(@order.id, true).deliver
        flash[:success] = Spree.t(:order_email_resent)

        redirect_to :back
      end

      def open_adjustments
        adjustments = @order.adjustments.where(:state => 'closed')
        adjustments.update_all(:state => 'open')
        flash[:success] = Spree.t(:all_adjustments_opened)

        respond_with(@order) { |format| format.html { redirect_to :back } }
      end

      def close_adjustments
        adjustments = @order.adjustments.where(:state => 'open')
        adjustments.update_all(:state => 'closed')
        flash[:success] = Spree.t(:all_adjustments_closed)

        respond_with(@order) { |format| format.html { redirect_to :back } }
      end

      private
        def order_params
          params[:created_by_id] = try_spree_current_user.try(:id)
          params.permit(:created_by_id)
        end

        def load_order
          @order = Order.includes(:adjustments).find_by_number!(params[:id])
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
          flash[:error] = Spree.t(:insufficient_stock_for_order)
          redirect_to cart_admin_order_url(@order)
        end
    end
  end
end
