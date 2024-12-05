# frozen_string_literal: true

module SolidusAdmin
  class TaxCategoriesController < SolidusAdmin::BaseController
    include SolidusAdmin::ControllerHelpers::Search

    before_action :set_tax_category, only: %i[edit update]

    def new
      @tax_category = Spree::TaxCategory.new

      set_index_page

      respond_to do |format|
        format.html { render component('tax_categories/new').new(page: @page, tax_category: @tax_category) }
      end
    end

    def edit
      @tax_category = Spree::TaxCategory.find(params[:id])

      set_index_page

      respond_to do |format|
        format.html { render component('tax_categories/edit').new(page: @page, tax_category: @tax_category) }
      end
    end

    def create
      @tax_category = Spree::TaxCategory.new(tax_category_params)

      if @tax_category.save
        respond_to do |format|
          flash[:notice] = t('.success')

          format.html do
            redirect_to solidus_admin.tax_categories_path, status: :see_other
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
            page_component = component('tax_categories/new').new(page: @page, tax_category: @tax_category)
            render page_component, status: :unprocessable_entity
          end
        end
      end
    end

    def update
      if @tax_category.update(tax_category_params)
        flash[:notice] = t('.success')
        redirect_to solidus_admin.tax_categories_path, status: :see_other
      else
        set_index_page

        respond_to do |format|
          format.html do
            page_component = component('tax_categories/edit').new(page: @page, tax_category: @tax_category)
            render page_component, status: :unprocessable_entity
          end
        end
      end
    end

    def index
      set_index_page

      respond_to do |format|
        format.html { render component('tax_categories/index').new(page: @page) }
      end
    end

    def destroy
      @tax_categories = Spree::TaxCategory.where(id: params[:id])

      Spree::TaxCategory.transaction { @tax_categories.destroy_all }

      flash[:notice] = t('.success')
      redirect_back_or_to tax_categories_path, status: :see_other
    end

    private

    def set_tax_category
      @tax_category = Spree::TaxCategory.find(params[:id])
    end

    def tax_category_params
      params.require(:tax_category).permit(:name, :description, :is_default, :tax_code)
    end

    def set_index_page
      tax_categories = apply_search_to(
        Spree::TaxCategory.order(created_at: :desc, id: :desc),
        param: :q,
      )

      set_page_and_extract_portion_from(tax_categories)
    end
  end
end
