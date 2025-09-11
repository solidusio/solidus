# frozen_string_literal: true

module SolidusAdmin
  class OrdersController < SolidusAdmin::BaseController
    include Spree::Core::ControllerHelpers::StrongParameters
    include SolidusAdmin::ControllerHelpers::Search

    search_scope(:completed, default: true) { _1.complete }
    search_scope(:canceled) { _1.canceled }
    search_scope(:returned) { _1.with_state(:returned) }
    search_scope(:in_progress) { _1.with_state([:cart] + _1.checkout_step_names) }
    search_scope(:all) { _1 }

    def index
      orders = apply_search_to(
        Spree::Order.order(created_at: :desc, id: :desc),
        param: :q
      )

      set_page_and_extract_portion_from(orders)

      respond_to do |format|
        format.html { render component("orders/index").new(page: @page) }
      end
    end

    def new
      order = Spree::Order.create!(
        created_by: current_solidus_admin_user,
        frontend_viewable: false,
        store_id: current_store.try(:id)
      )

      redirect_to order_url(order), status: :see_other
    end

    def show
      load_order

      respond_to do |format|
        format.html { render component("orders/show").new(order: @order) }
      end
    end

    def update
      load_order

      @order.assign_attributes(order_params)
      @order.email ||= @order.user.email if @order.user && @order.user.changed?

      if @order.save
        flash[:notice] = t(".success")
      else
        flash[:error] = t(".error")
      end

      respond_to do |format|
        format.html { redirect_to spree.edit_admin_order_path(@order) }

        format.turbo_stream { render turbo_stream: '<turbo-stream action="refresh" />' }
      end
    end

    def edit
      redirect_to action: :show
    end

    def variants_for
      load_order

      # We need to eager load active storage attachments when using it
      if Spree::Image.include?(Spree::Image::ActiveStorageAttachment)
        image_includes = {
          attachment_attachment: {blob: {variant_records: {image_attachment: :blob}}}
        }
      end

      @variants = Spree::Variant
        .where.not(id: @order.line_items.select(:variant_id))
        .order(created_at: :desc, id: :desc)
        .where(product_id: Spree::Product.ransack(params[:q]).result.select(:id))
        .limit(10)
        .eager_load(
          :prices,
          images: image_includes || {},
          option_values: :option_type,
          stock_items: :stock_location
        )

      respond_to do |format|
        format.html { render component("orders/cart/result").with_collection(@variants, order: @order), layout: false }
      end
    end

    def customers_for
      load_order

      @users = Spree.user_class
        .where.not(id: @order.user_id)
        .order(created_at: :desc, id: :desc)
        .ransack(params[:q])
        .result(distinct: true)
        .includes(:default_user_bill_address, :default_user_ship_address)
        .limit(10)

      respond_to do |format|
        format.html { render component("orders/show/customer_search/result").with_collection(@users, order: @order), layout: false }
      end
    end

    private

    def load_order
      @order = Spree::Order.find_by!(number: params[:id])
      authorize! action_name, @order
    end

    def order_params
      params.require(:order).permit(:user_id, permitted_order_attributes)
    end
  end
end
