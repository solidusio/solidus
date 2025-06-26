# frozen_string_literal: true

module SolidusAdmin
  class TaxRatesController < SolidusAdmin::ResourcesController
    include SolidusAdmin::ControllerHelpers::Search

    def index
      tax_rates = apply_search_to(
        Spree::TaxRate.order(created_at: :desc, id: :desc),
        param: :q
      )

      set_page_and_extract_portion_from(tax_rates)

      respond_to do |format|
        format.html { render component("tax_rates/index").new(page: @page) }
      end
    end

    def destroy
      @tax_rates = Spree::TaxRate.where(id: params[:id])

      Spree::TaxRate.transaction { @tax_rates.destroy_all }

      flash[:notice] = t(".success")
      redirect_back_or_to tax_rates_path, status: :see_other
    end

    private

    def resource_class = Spree::TaxRate

    def resources_collection
      resource_class.includes(:zone, :tax_categories, :calculator)
    end

    def resources_sorting_options = {created_at: :desc, id: :desc}

    def permitted_resource_params
      params.require(:tax_rate).permit(:name, :zone_id, :show_rate_in_label, :calculator_type, :amount, :level,
        :included_in_price, :starts_at, :expires_at, tax_category_ids: [])
    end
  end
end
