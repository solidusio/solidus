# frozen_string_literal: true

module SolidusAdmin
  class ReturnReasonsController < SolidusAdmin::BaseController
    include SolidusAdmin::ControllerHelpers::Search

    before_action :set_return_reason, only: %i[edit update]

    def index
      set_index_page

      respond_to do |format|
        format.html { render component('return_reasons/index').new(page: @page) }
      end
    end

    def new
      @return_reason = Spree::ReturnReason.new

      respond_to do |format|
        format.html { render component('return_reasons/new').new(return_reason: @return_reason) }
      end
    end

    def create
      @return_reason = Spree::ReturnReason.new(return_reason_params)

      if @return_reason.save
        flash[:notice] = t('.success')
        redirect_to solidus_admin.return_reasons_path(**search_filter_params), status: :see_other
      else
        respond_to do |format|
          format.html do
            page_component = component('return_reasons/new').new(return_reason: @return_reason)
            render page_component, status: :unprocessable_entity
          end
          format.turbo_stream do
            render status: :unprocessable_entity
          end
        end
      end
    end

    def edit
      render component('return_reasons/edit').new(return_reason: @return_reason)
    end

    def update
      if @return_reason.update(return_reason_params)
        flash[:notice] = t('.success')
        redirect_to solidus_admin.return_reasons_path(**search_filter_params), status: :see_other
      else
        respond_to do |format|
          format.html do
            page_component = component('return_reasons/edit').new(return_reason: @return_reason)
            render page_component, status: :unprocessable_entity
          end
          format.turbo_stream do
            render status: :unprocessable_entity
          end
        end
      end
    end

    def destroy
      @return_reason = Spree::ReturnReason.find_by!(id: params[:id])

      Spree::ReturnReason.transaction { @return_reason.destroy }

      flash[:notice] = t('.success')
      redirect_back_or_to return_reasons_path(**search_filter_params), status: :see_other
    end

    private

    def set_return_reason
      @return_reason = Spree::ReturnReason.find(params[:id])
    end

    def set_index_page
      return_reasons = apply_search_to(
        Spree::ReturnReason.unscoped.order(id: :desc),
        param: :q,
      )

      set_page_and_extract_portion_from(return_reasons)
    end

    def return_reason_params
      params.require(:return_reason).permit(:name, :active)
    end
  end
end
