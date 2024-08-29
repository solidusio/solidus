# frozen_string_literal: true

module SolidusAdmin
  class TaxRatesController < SolidusAdmin::BaseController
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

    def tax_rate_params
      params.require(:tax_rate).permit(:tax_rate_id, permitted_tax_rate_attributes)
    end
  end
end
