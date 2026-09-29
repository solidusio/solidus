# frozen_string_literal: true

class SolidusAdmin::Products::Show::Categories::New::Component < SolidusAdmin::BaseComponent
  def initialize(product:, taxon: nil)
    @product = product
    @taxon = taxon || product.taxons.build
  end

  def selected_parent_option
    return [] unless (parent = @taxon.parent)

    [[parent.pretty_name, parent.id]]
  end
end
