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
      columns: columns,
      page: nil,
      per_page: nil
    }
  end

  def sortable_options
    {
      url: ->(image) {
        solidus_admin.move_product_image_path(product, image)
      },
      param: "position",
      handle: ".handle",
      turbo_frame: :product_media_frame
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
              tag.div(class: "w-12 h-12 bg-gray-200 rounded")
            end
          else
            tag.div(class: "w-12 h-12 bg-gray-200 rounded")
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
      },
      {
        header: -> { tag.span(t(".edit"), class: "sr-only") },
        data: ->(image) {
          render component("ui/button").new(
            tag: :a,
            href: solidus_admin.edit_product_image_path(product, image),
            scheme: :ghost,
            icon: "pencil-line",
            "aria-label": t(".edit"),
            data: {turbo_frame: :edit_image_modal}
          )
        },
        col: {class: "w-12"}
      },
      {
        header: -> { tag.span(t(".reorder"), class: "sr-only") },
        data: ->(_) {
          component("ui/icon")
            .new(name: "draggable", class: "h-5 cursor-pointer handle")
        },
        col: {class: "w-12"}
      }
    ]
  end

  def human_size(size) = number_to_human_size(size)
end
