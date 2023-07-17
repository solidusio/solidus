# frozen_string_literal: true

module SolidusAdmin
  class ProductsController < SolidusAdmin::BaseController
    def index
      set_page_and_extract_portion_from(
        Spree::Product.order(created_at: :desc, id: :desc),
        per_page: SolidusAdmin::Config[:products_per_page]
      )
    end
  end
end
