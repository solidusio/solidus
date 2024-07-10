# frozen_string_literal: true

module SolidusAdmin
  class ReturnReasonsController < SolidusAdmin::BaseController
    include SolidusAdmin::ControllerHelpers::Search

    def index
      set_index_page

      respond_to do |format|
        format.html { render component('return_reasons/index').new(page: @page) }
      end
    end

    def new
      @return_reason = Spree::ReturnReason.new

      set_index_page

      respond_to do |format|
        format.html {
          render component('return_reasons/new')
            .new(page: @page, return_reason: @return_reason)
        }
      end
    end

    def create
      @return_reason = Spree::ReturnReason.new(return_reason_params)

      if @return_reason.save
        respond_to do |format|
          flash[:notice] = t('.success')

          format.html do
            redirect_to solidus_admin.return_reasons_path, status: :see_other
          end

          format.turbo_stream do
            render turbo_stream: '<turbo-stream action="refresh" />'
          end
        end
      else
        set_index_page

        respond_to do |format|
          format.html do
            page_component = component('return_reasons/new')
              .new(page: @page, return_reason: @return_reason)

            render page_component, status: :unprocessable_entity
          end
        end
      end
    end

    def destroy
      @return_reason = Spree::ReturnReason.find_by!(id: params[:id])

      Spree::ReturnReason.transaction { @return_reason.destroy }

      flash[:notice] = t('.success')
      redirect_back_or_to return_reasons_path, status: :see_other
    end

    private

    def set_index_page
      return_reasons = apply_search_to(
        Spree::ReturnReason.unscoped.order(id: :desc),
        param: :q,
      )

      set_page_and_extract_portion_from(return_reasons)
    end

    def load_return_reason
      @return_reason = Spree::ReturnReason.find_by!(id: params[:id])
      authorize! action_name, @return_reason
    end

    def return_reason_params
      params.require(:return_reason).permit(:name, :active)
    end
  end
end
