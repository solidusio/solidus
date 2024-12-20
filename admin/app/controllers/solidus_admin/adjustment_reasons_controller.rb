# frozen_string_literal: true

module SolidusAdmin
  class AdjustmentReasonsController < SolidusAdmin::BaseController
    include SolidusAdmin::ControllerHelpers::Search

    before_action :set_adjustment_reason, only: %i[edit update]

    def index
      set_index_page

      respond_to do |format|
        format.html { render component('adjustment_reasons/index').new(page: @page) }
      end
    end

    def new
      @adjustment_reason = Spree::AdjustmentReason.new

      set_index_page

      respond_to do |format|
        format.html { render component('adjustment_reasons/new').new(page: @page, adjustment_reason: @adjustment_reason) }
      end
    end

    def create
      @adjustment_reason = Spree::AdjustmentReason.new(adjustment_reason_params)

      if @adjustment_reason.save
        respond_to do |format|
          flash[:notice] = t('.success')

          format.html do
            redirect_to solidus_admin.adjustment_reasons_path, status: :see_other
          end

          format.turbo_stream do
            render turbo_stream: '<turbo-stream action="refresh" />'
          end
        end
      else
        set_index_page

        respond_to do |format|
          format.html do
            page_component = component('adjustment_reasons/new').new(page: @page, adjustment_reason: @adjustment_reason)
            render page_component, status: :unprocessable_entity
          end
        end
      end
    end

    def edit
      respond_to do |format|
        format.html do
          if turbo_frame_request?
            render component('adjustment_reasons/edit').new(adjustment_reason: @adjustment_reason), layout: false
          else
            set_index_page
          end
        end
      end
    end

    def update
      if @adjustment_reason.update(adjustment_reason_params)
        respond_to do |format|
          flash[:notice] = t('.success')

          format.html do
            redirect_to solidus_admin.adjustment_reasons_path, status: :see_other
          end

          format.turbo_stream do
            render turbo_stream: '<turbo-stream action="refresh" />'
          end
        end
      else
        set_index_page

        respond_to do |format|
          format.html do
            page_component = component('adjustment_reasons/edit').new(adjustment_reason: @adjustment_reason)
            render page_component, status: :unprocessable_entity
          end
        end
      end
    end

    def destroy
      @adjustment_reason = Spree::AdjustmentReason.find_by!(id: params[:id])

      Spree::AdjustmentReason.transaction { @adjustment_reason.destroy }

      flash[:notice] = t('.success')
      redirect_back_or_to adjustment_reasons_path, status: :see_other
    end

    private

    def set_adjustment_reason
      @adjustment_reason = Spree::AdjustmentReason.find(params[:id])
    end

    def adjustment_reason_params
      params.require(:adjustment_reason).permit(:name, :code, :active)
    end

    def set_index_page
      adjustment_reasons = apply_search_to(
        Spree::AdjustmentReason.order(id: :desc),
        param: :q,
      )

      set_page_and_extract_portion_from(adjustment_reasons)
    end
  end
end
