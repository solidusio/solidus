# frozen_string_literal: true

class SolidusAdmin::Products::Show::Images::New::Component < SolidusAdmin::BaseComponent
  def initialize(product:, image: Spree::Image.new, flash: {})
    @product = product
    @image = image
    @flash = flash
  end

  def error_message = @flash[:error].to_s
end
