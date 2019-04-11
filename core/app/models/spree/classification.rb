# frozen_string_literal: true

module Spree
  class Classification < Spree::Base
    self.table_name = 'spree_products_taxons'
    acts_as_list scope: :taxon
    belongs_to :product, class_name: "Spree::Product", inverse_of: :classifications, touch: true, optional: true
    belongs_to :taxon, class_name: "Spree::Taxon", inverse_of: :classifications, touch: true, optional: true

    # For https://github.com/spree/spree/issues/3494
    validates_uniqueness_of :taxon_id, scope: :product_id, message: :already_linked

    # We can not rely on html element position index, there could be gaps between
    # positions due discarded products, their classification is destroyed
    # but taxon classifications are not rebuilt leaving gaps
    def insert_at(position)
      return false if invalid_position(position)

      real_position = taxon.classifications.order(:position).to_a[position].position
      super(real_position)
    end

    private

    def last_position
      taxon.classifications.count - 1
    end

    def invalid_position(position)
      unless (0..last_position).cover? position
        errors.add(:position, "must be within 0..#{last_position}")
        true
      end
    end
  end
end
