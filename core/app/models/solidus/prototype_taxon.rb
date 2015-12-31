module Solidus
  class PrototypeTaxon < Solidus::Base
    belongs_to :prototype
    belongs_to :taxon
  end
end
