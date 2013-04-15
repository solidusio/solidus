module Spree
  class Admin::TranslationsController < Admin::BaseController
    before_filter :load_parent

    helper_method :collection_url
    helper 'spree/locale'

    private

      def load_parent
        @product ||= Spree::Product.find_by_permalink(params[:product_id])
      end

      def collection_url
        admin_product_url(load_parent)
      end
  end
end
