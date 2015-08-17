module Spree
  class PrototypeProperty < Spree::Base
    self.table_name = 'spree_properties_prototypes'

    belongs_to :prototype
    belongs_to :property
  end
end
