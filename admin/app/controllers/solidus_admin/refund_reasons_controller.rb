# frozen_string_literal: true

module SolidusAdmin
  class RefundReasonsController < SolidusAdmin::BaseController
    include SolidusAdmin::ControllerHelpers::Search

    before_action :find_refund_reason, only: %i[edit update]

    def index
      set_index_page

      respond_to do |format|
        format.html { render component('refund_reasons/index').new(page: @page) }
      end
    end

    def new
      @refund_reason = Spree::RefundReason.new

      set_index_page

      respond_to do |format|
        format.html { render component('refund_reasons/new').new(page: @page, refund_reason: @refund_reason) }
      end
    end

    def create
      @refund_reason = Spree::RefundReason.new(refund_reason_params)

      if @refund_reason.save
        respond_to do |format|
          flash[:notice] = t('.success')

          format.html do
            redirect_to solidus_admin.refund_reasons_path, status: :see_other
          end

          format.turbo_stream do
            render turbo_stream: '<turbo-stream action="refresh" />'
          end
        end
      else
        set_index_page

        respond_to do |format|
          format.html do
            page_component = component('refund_reasons/new').new(page: @page, refund_reason: @refund_reason)
            render page_component, status: :unprocessable_entity
          end
        end
      end
    end

    def edit
      set_index_page

      respond_to do |format|
        format.html { render component('refund_reasons/edit').new(page: @page, refund_reason: @refund_reason) }
      end
    end

    def update
      if @refund_reason.update(refund_reason_params)
        respond_to do |format|
          flash[:notice] = t('.success')

          format.html do
            redirect_to solidus_admin.refund_reasons_path, status: :see_other
          end

          format.turbo_stream do
            render turbo_stream: '<turbo-stream action="refresh" />'
          end
        end
      else
        set_index_page

        respond_to do |format|
          format.html do
            page_component = component('refund_reasons/edit').new(page: @page, refund_reason: @refund_reason)
            render page_component, status: :unprocessable_entity
          end
        end
      end
    end

    def destroy
      @refund_reason = Spree::RefundReason.find_by!(id: params[:id])

      Spree::RefundReason.transaction { @refund_reason.destroy }

      flash[:notice] = t('.success')
      redirect_back_or_to refund_reasons_path, status: :see_other
    end

    private

    def load_refund_reason
      @refund_reason = Spree::RefundReason.find_by!(id: params[:id])
      authorize! action_name, @refund_reason
    end

    def find_refund_reason
      @refund_reason = Spree::RefundReason.find(params[:id])
    end

    def refund_reason_params
      params.require(:refund_reason).permit(:name, :code, :active)
    end

    def set_index_page
      refund_reasons = apply_search_to(
        Spree::RefundReason.unscoped.order(id: :desc),
        param: :q,
      )

      set_page_and_extract_portion_from(refund_reasons)
    end
  end
end
