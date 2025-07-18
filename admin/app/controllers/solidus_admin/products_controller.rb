# frozen_string_literal: true

module SolidusAdmin
  class ProductsController < SolidusAdmin::BaseController
    include SolidusAdmin::ControllerHelpers::Search

    search_scope(:all, default: true)
    search_scope(:deleted) { _1.with_discarded.discarded }
    search_scope(:discontinued) { _1.where(discontinue_on: ...Time.current) }
    search_scope(:available) { _1.available }
    search_scope(:in_stock) { _1.where(id: Spree::Variant.in_stock.distinct.select(:product_id)) }
    search_scope(:out_of_stock) { _1.where.not(id: Spree::Variant.in_stock.distinct.select(:product_id)) }

    def index
      products = apply_search_to(
        Spree::Product.includes(:master, :variants),
        param: :q,
      )

      set_page_and_extract_portion_from(
        products,
        ordered_by: { updated_at: :desc, id: :desc },
      )

      respond_to do |format|
        format.html { render component('products/index').new(page: @page) }
      end
    end

    def edit
      redirect_to action: :show
    end

    def show
      @product = Spree::Product.with_discarded.friendly.find(params[:id])

      respond_to do |format|
        format.html { render component('products/show').new(product: @product) }
      end
    end

    def update
      @product = Spree::Product.friendly.find(params[:id])

      if @product.update(product_params)
        flash[:notice] = t('spree.successfully_updated', resource: [
          Spree::Product.model_name.human,
          @product.name.inspect,
        ].join(' '))

        redirect_to action: :show, status: :see_other
      else
        flash.now[:error] = @product.errors.full_messages.join(", ")

        respond_to do |format|
          format.html { render component('products/show').new(product: @product), status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @products = Spree::Product.where(id: params[:id])

      Spree::Product.transaction do
        @products.discard_all
      end

      flash[:notice] = t('.success')
      redirect_to products_path, status: :see_other
    end

    def discontinue
      @products = Spree::Product.where(id: params[:id])

      Spree::Product.transaction do
        @products
          .update_all(discontinue_on: Time.current)
      end

      flash[:notice] = t('.success')
      redirect_to products_path, status: :see_other
    end

    def activate
      @products = Spree::Product.where(id: params[:id])

      Spree::Product.transaction do
        @products
          .where.not(discontinue_on: nil)
          .update_all(discontinue_on: nil)

        @products
          .where("available_on <= ?", Time.current)
          .or(@products.where(available_on: nil))
          .update_all(discontinue_on: nil)
      end

      flash[:notice] = t('.success')
      redirect_to products_path, status: :see_other
    end

    private

    def product_params
      params.require(:product).permit(:name, :slug, :description, :meta_title, :meta_description, :meta_keywords, :gtin,
        :condition, :price, :cost_price, :cost_currency, :sku, :shipping_category_id, :tax_category_id,
        :available_on, :discontinue_on, :promotionable, option_type_ids: [], taxon_ids: [])
    end
  end
end
