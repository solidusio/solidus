# frozen_string_literal: true

module SolidusAdmin
  class StoresController < SolidusAdmin::BaseController
    include SolidusAdmin::ControllerHelpers::Search

    def index
      stores = apply_search_to(
        Spree::Store.order(id: :desc),
        param: :q
      )

      set_page_and_extract_portion_from(stores)

      respond_to do |format|
        format.html { render component('stores/index').new(page: @page) }
      end
    end

    def new
      @store ||= Spree::Store.new

      respond_to do |format|
        format.html {
          render component("stores/new").new(
            store: @store
          )
        }
      end
    end

    def edit
      @store = Spree::Store.find_by(id: params[:id])

      respond_to do |format|
        format.html { render component('stores/edit').new(store: @store) }
      end
    end

    def destroy
      @stores = Spree::Store.where(id: params[:id])

      Spree::Store.transaction { @stores.destroy_all }

      flash[:notice] = t('.success')
      redirect_back_or_to stores_path, status: :see_other
    end

    private

    def store_params
      params.require(:store).permit(:store_id, permitted_store_attributes)
    end
  end
end
