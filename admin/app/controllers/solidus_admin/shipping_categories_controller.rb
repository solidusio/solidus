# frozen_string_literal: true

module SolidusAdmin
  class ShippingCategoriesController < SolidusAdmin::BaseController
    include SolidusAdmin::ControllerHelpers::Search

    before_action :set_shipping_category, only: %i[edit update]

    def new
      @shipping_category = Spree::ShippingCategory.new

      set_index_page

      respond_to do |format|
        format.html do
          render component('shipping_categories/new').new(page: @page, shipping_category: @shipping_category), layout: false
        end
      end
    end

    def create
      @shipping_category = Spree::ShippingCategory.new(shipping_category_params)

      if @shipping_category.save
        respond_to do |format|
          flash[:notice] = t('.success')

          format.html do
            redirect_to solidus_admin.shipping_categories_path, status: :see_other
          end

          format.turbo_stream do
            # we need to explicitly write the refresh tag for now.
            # See https://github.com/hotwired/turbo-rails/issues/579
            render turbo_stream: '<turbo-stream action="refresh" />'
          end
        end
      else
        set_index_page

        respond_to do |format|
          format.html do
            page_component = component('shipping_categories/new').new(page: @page, shipping_category: @shipping_category)
            render page_component, status: :unprocessable_entity
          end
        end
      end
    end

    def index
      set_index_page

      respond_to do |format|
        format.html { render component('shipping_categories/index').new(page: @page) }
      end
    end

    def edit
      set_index_page

      respond_to do |format|
        format.html do
          render component('shipping_categories/edit').new(page: @page, shipping_category: @shipping_category), layout: false
        end
      end
    end

    def update
      if @shipping_category.update(shipping_category_params)
        respond_to do |format|
          flash[:notice] = t('.success')

          format.html do
            redirect_to solidus_admin.shipping_categories_path, status: :see_other
          end

          format.turbo_stream do
            render turbo_stream: '<turbo-stream action="refresh" />'
          end
        end
      else
        set_index_page

        respond_to do |format|
          format.html do
            page_component = component('shipping_categories/edit').new(page: @page, shipping_category: @shipping_category)
            render page_component, status: :unprocessable_entity
          end
        end
      end
    end

    def destroy
      @shipping_category = Spree::ShippingCategory.find_by!(id: params[:id])

      Spree::ShippingCategory.transaction { @shipping_category.destroy }

      flash[:notice] = t('.success')
      redirect_back_or_to shipping_categories_path, status: :see_other
    end

    private

    def set_shipping_category
      @shipping_category = Spree::ShippingCategory.find(params[:id])
    end

    def shipping_category_params
      params.require(:shipping_category).permit(:name)
    end

    def set_index_page
      shipping_categories = apply_search_to(
        Spree::ShippingCategory.order(id: :desc),
        param: :q,
      )

      set_page_and_extract_portion_from(shipping_categories)
    end
  end
end
