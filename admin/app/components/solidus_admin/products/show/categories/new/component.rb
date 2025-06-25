# frozen_string_literal: true

class SolidusAdmin::Products::Show::Categories::New::Component < SolidusAdmin::BaseComponent
  def initialize(product:, taxon: nil)
    @product = product
    @taxon = taxon || product.taxons.build
  end

  private

  def parent_taxon_options
    @parent_taxon_options ||= Spree::Taxon.order(:lft).pluck(:name, :id, :depth).map do
      name, id, depth = _1
      ["#{'    ' * depth} → #{name}", id, { data: { item_label: name } }]
    end
  end
end
