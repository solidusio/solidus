# frozen_string_literal: true

module SolidusAdmin
  class ProductsController < SolidusAdmin::BaseController
    def index
      @search_key = search_key
      @query_params = product_params[:q]
      @q = Spree::Product.ransack(@query_params)

      @products = @q.result(distinct: true).order(created_at: :desc, id: :desc)

      set_page_and_extract_portion_from(
        @products,
        per_page: SolidusAdmin::Config[:products_per_page]
      )
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
      params.permit(:page, q: [search_key])
    end

    def search_key
      SolidusAdmin::Config[:product_search_key]
    end
  end
end
