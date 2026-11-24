# frozen_string_literal: true

class SolidusAdmin::Products::Show::Images::New::Component < SolidusAdmin::BaseComponent
  def initialize(product:, image:)
    @product = product
    @image = image
  end
end
