# frozen_string_literal: true

class SolidusAdmin::Products::Show::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  def initialize(product:)
    @product = product
  end

  def form_id
    @form_id ||= "#{stimulus_id}--form-#{@product.id}"
  end

  private

  def taxon_options
    @taxon_options ||= Spree::Taxon.order(:lft).pluck(:name, :id, :lft, :depth).map do
      name, id, _lft, depth = _1
      ["#{"    " * depth} → #{name}", id]
    end
  end

  def option_type_options
    @option_type_options ||= Spree::OptionType.order(:presentation).pluck(:presentation, :name, :id).map do
      ["#{_1} (#{_2})", _3]
    end
  end

  def condition_options
    @condition_options ||= Spree::Variant.conditions.map do |key, value|
      [t("spree.condition.#{key}"), value]
    end
  end
end
