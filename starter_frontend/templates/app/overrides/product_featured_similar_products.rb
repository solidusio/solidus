# frozen_string_literal: true

module ProductFeaturedSimilarProducts
  def self.prepended(base)
    base.scope :featured, -> { where(featured: true) }
  end

  def similar_products(limit = 3)
    taxons.map do |taxon|
      taxon.all_products_except(self.id)
    end.flatten.uniq.first(limit)
  end

  Spree::Product.prepend self
end
