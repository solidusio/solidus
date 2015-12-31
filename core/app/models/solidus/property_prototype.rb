module Spree
  class PropertyPrototype < Solidus::Base
    belongs_to :prototype
    belongs_to :property
  end
end
