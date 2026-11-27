# frozen_string_literal: true

class SolidusAdmin::Products::Show::Images::Edit::Component < SolidusAdmin::BaseComponent
  include ActionView::Helpers::NumberHelper

  def initialize(product:, image:)
    @product = product
    @image = image
  end

  def form_id
    dom_id(@image, "edit_image_form")
  end

  def form_url
    solidus_admin.product_image_path(@product, @image)
  end

  def back_url
    solidus_admin.product_path(@product)
  end

  def human_size(size)
    number_to_human_size(size)
  end

  def image_with_fallback(image)
    image_tag(image.url(:mini), class: "w-16 h-16 object-cover rounded")
  rescue
    content_tag(:div, class: "w-16 h-16 bg-gray-200 rounded")
  end
end
