# frozen_string_literal: true

module SolidusAdmin
  class TaxonsController < SolidusAdmin::BaseController
    RESPONSE_FIELDS = [:id, :pretty_name]

    def pretty_names
      render json: taxons_with_parents.map { |taxon|
        RESPONSE_FIELDS.to_h { [_1, taxon.public_send(_1)] }
      }
    end

    private

    def taxons_with_parents
      taxons = Spree::Taxon
        .joins(:taxonomy)
        .order(
          Spree::Taxonomy.arel_table[:position].asc,
          Spree::Taxon.arel_table[:lft].asc
        )
      taxons.associate_parents(taxons)
    end
  end
end
