module Spree
  class PrototypeTaxon < Spree::Base
    self.table_name = 'spree_taxons_prototypes'

    belongs_to :taxon
    belongs_to :prototype
  end
end
