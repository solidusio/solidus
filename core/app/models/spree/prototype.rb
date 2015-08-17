module Spree
  class Prototype < Spree::Base
    has_many :prototype_properties
    has_many :properties, through: :prototype_properties

    has_many :option_type_prototypes
    has_many :option_types, through: :option_type_prototypes

    has_many :prototype_taxons
    has_many :taxons, through: :prototype_taxons

    validates :name, presence: true
  end
end
