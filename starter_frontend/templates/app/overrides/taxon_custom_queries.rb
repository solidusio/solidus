# frozen_string_literal: true

module TaxonCustomQueries
  def featured(limit = 3)
    all_products.featured.order('RANDOM()').limit(limit)
  end

  def all_products_except(product_ids)
    all_products.where.not(id: product_ids)
  end

  Spree::Taxon.prepend self
end
