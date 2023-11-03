# frozen_string_literal: true

module SolidusAdmin
  class OrdersController < SolidusAdmin::BaseController
    include Spree::Core::ControllerHelpers::StrongParameters

    def index
      orders = Spree::Order
        .order(created_at: :desc, id: :desc)
        .ransack(params[:q])
        .result(distinct: true)

      set_page_and_extract_portion_from(
        orders,
        per_page: SolidusAdmin::Config[:orders_per_page]
      )

      respond_to do |format|
        format.html { render component('orders/index').new(page: @page) }
      end
    end

    def show
      load_order

      respond_to do |format|
        format.html { render component('orders/show').new(order: @order) }
      end
    end

    def update
      load_order

      @order.assign_attributes(order_params)
      @order.email ||= @order.user.email if @order.user && @order.user.changed?

      if @order.save
        flash[:notice] = t('.success')
      else
        flash[:error] = t('.error')
      end

      redirect_to spree.edit_admin_order_path(@order)
    end

    def edit
      redirect_to action: :show
    end

    def variants_for
      load_order

      # We need to eager load active storage attachments when using it
      if Spree::Image.include?(Spree::Image::ActiveStorageAttachment)
        image_includes = {
          attachment_attachment: { blob: { variant_records: { image_attachment: :blob } } }
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
          stock_items: :stock_location,
        )

      respond_to do |format|
        format.html { render component('orders/cart/result').with_collection(@variants, order: @order), layout: false }
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
