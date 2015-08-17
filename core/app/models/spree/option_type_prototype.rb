module Spree
  class OptionTypePrototype < Spree::Base
    self.table_name = 'spree_option_types_prototypes'

    belongs_to :option_type
    belongs_to :prototype
  end
end
