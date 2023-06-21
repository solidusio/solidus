# frozen_string_literal: true

class SolidusAdmin::Products::Index::Component < SolidusAdmin::BaseComponent
  def initialize(products:)
    @products = products
  end
end
