# frozen_string_literal: true

module SolidusAdmin
  class ProductsController < SolidusAdmin::BaseController
    def index
      @products = Spree::Product.all
    end
  end
end
