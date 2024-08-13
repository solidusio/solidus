# frozen_string_literal: true

module SolidusAdmin
  class StoreCreditReasonsController < SolidusAdmin::BaseController
    include SolidusAdmin::ControllerHelpers::Search

    def index
      set_index_page

      respond_to do |format|
        format.html { render component('store_credit_reasons/index').new(page: @page) }
      end
    end

    def new
      @store_credit_reason = Spree::StoreCreditReason.new

      set_index_page

      respond_to do |format|
        format.html { render component('store_credit_reasons/new').new(page: @page, store_credit_reason: @store_credit_reason) }
      end
    end

    def create
      @store_credit_reason = Spree::StoreCreditReason.new(store_credit_reason_params)

      if @store_credit_reason.save
        respond_to do |format|
          flash[:notice] = t('.success')

          format.html do
            redirect_to solidus_admin.store_credit_reasons_path, status: :see_other
          end

          format.turbo_stream do
            render turbo_stream: '<turbo-stream action="refresh" />'
          end
        end
      else
        set_index_page

        respond_to do |format|
          format.html do
            page_component = component('store_credit_reasons/new').new(page: @page, store_credit_reason: @store_credit_reason)
            render page_component, status: :unprocessable_entity
          end
        end
      end
    end

    def destroy
      @store_credit_reason = Spree::StoreCreditReason.find_by!(id: params[:id])

      Spree::StoreCreditReason.transaction { @store_credit_reason.destroy }

      flash[:notice] = t('.success')
      redirect_back_or_to store_credit_reasons_path, status: :see_other
    end

    private

    def load_store_credit_reason
      @store_credit_reason = Spree::StoreCreditReason.find_by!(id: params[:id])
      authorize! action_name, @store_credit_reason
    end

    def store_credit_reason_params
      params.require(:store_credit_reason).permit(:name, :active)
    end

    def set_index_page
      store_credit_reasons = apply_search_to(
        Spree::StoreCreditReason.unscoped.order(id: :desc),
        param: :q,
      )

      set_page_and_extract_portion_from(store_credit_reasons)
    end
  end
end
