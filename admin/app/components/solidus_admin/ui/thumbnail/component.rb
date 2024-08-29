# frozen_string_literal: true

class SolidusAdmin::UI::Thumbnail::Component < SolidusAdmin::BaseComponent
  SIZES = {
    s: "h-6 w-6",
    m: "h-10 w-10",
    l: "h-20 w-20"
  }.freeze

  def initialize(icon: nil, size: :m, **attributes)
    @icon = icon
    @size = size
    @attributes = attributes
  end

  def call
    icon = if @icon
      icon_tag(@icon, class: "bg-gray-25 fill-gray-700 #{SIZES[@size]} p-2")
    else
      tag.img(**@attributes, class: "object-contain #{SIZES[@size]}")
    end

    tag.div(icon, class: "
      #{SIZES[@size]}
      rounded border border-gray-100
      bg-white overflow-hidden
      content-box
      #{@attributes[:class]}
    ")
  end

  def self.for(record, **attrs)
    case record
    when *Spree::Config.adjustment_promotion_source_types then new(icon: "megaphone-line", **attrs)
    when Spree::UnitCancel then new(icon: "close-circle-line", **attrs)
    when Spree::TaxRate then new(icon: "percent-line", **attrs)
    when Spree::LineItem then self.for(record.variant, **attrs)
    when Spree::Product then self.for(record.images.first || record.master.images.first, **attrs)
    when Spree::Variant then self.for(record.images.first || record.product, **attrs)
    when Spree::Image then new(src: record.attachment&.url(:small), alt: record.alt, **attrs)
    when Spree::Order then new(icon: "shopping-bag-line", **attrs)
    when Spree::Shipment then new(icon: "truck-line", **attrs)
    else new(icon: "question-line", **attrs)
    end
  end
end
