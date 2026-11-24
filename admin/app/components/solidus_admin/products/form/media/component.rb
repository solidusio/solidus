# frozen_string_literal: true

class SolidusAdmin::Products::Form::Media::Component < SolidusAdmin::BaseComponent
  include ActionView::Helpers::NumberHelper

  def initialize(form:)
    @form = form
  end

  def product = @form.object

  def images = product.images

  def table_data
    {
      rows: images,
      class: Spree::Image,
      batch_actions: batch_actions,
      columns: columns
    }
  end

  def batch_actions
    [
      {
        label: t(".batch_actions.destroy"),
        action: solidus_admin.product_images_path(product),
        method: :delete,
        icon: "delete-bin-7-line",
        require_confirmation: true
      }
    ]
  end

  def columns
    [
      {
        header: -> { tag.span(t(".image"), class: "sr-only") },
        data: ->(image) {
          if image.attachment.attached?
            begin
              image_tag image.url(:mini), class: "w-12 h-12 object-cover rounded"
            rescue
              tag.div(nil, class: "w-12 h-12 bg-gray-200 rounded")
            end
          else
            tag.div(nil, class: "w-12 h-12 bg-gray-200 rounded")
          end
        }
      },
      {
        header: t(".filename"),
        data: ->(image) {
          render component("products/form/filename_info")
            .new(filename: image.attachment.filename)
        }
      },
      {
        header: -> { tag.span(t(".featured"), class: "sr-only") },
        data: ->(image) {
          return unless image.position == 1
          render component("ui/badge").new(name: t(".featured"), color: :green)
        }
      },
      {
        header: t(".date_added"),
        data: ->(image) { image.created_at.strftime("%b %d, %Y") }
      },
      {
        header: t(".size"),
        data: ->(image) { human_size(image.attachment.byte_size) if image.attachment.attached? }
      }
    ]
  end

  def human_size(size) = number_to_human_size(size)
end
