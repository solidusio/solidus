module Spree
  module Api
    class AvailableLocalesController < Spree::Api::BaseController
      def index
        respond_with Store.all
      end

      def update
        authorize! :update, store
        if store.update_attributes(store_params)
          respond_with(store, status: 200, default_template: :show)
        else
          invalid_resource!(store)
        end
      end

      private

      def store_params
        params.require(:store).permit(preferred_available_locales: [])
      end

      def store
        @store ||= Store.find(params[:id])
      end
    end
  end
end
