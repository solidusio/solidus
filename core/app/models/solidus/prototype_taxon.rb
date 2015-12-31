module Spree
  class PrototypeTaxon < Spree::Base
    belongs_to :prototype
    belongs_to :taxon
  end
end
