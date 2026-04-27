# frozen_string_literal: true

class ImageComponent < ViewComponent::Base
  attr_reader :image, :size, :classes, :options

  def initialize(local_assigns = {})
    @image = local_assigns.delete(:image)
    @size = local_assigns.delete(:size) { :mini }
    @classes = local_assigns.delete(:classes)
    @options = local_assigns
  end

  def call
    if image
      image_tag image.url(size), default_options.merge(options)
    else
      content_tag :div, nil, class: ['image-placeholder', size].join(' ')
    end
  end

  private

  def default_options
    { alt: image.alt, class: classes }
  end
end
