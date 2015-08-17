module Spree
  class PrototypeProperty < Spree::Base
    belongs_to :prototype
    belongs_to :property
  end
end
