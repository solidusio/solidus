module Spree
  class Prototype < Spree::Base
    has_and_belongs_to_many :option_types, join_table: :spree_option_types_prototypes

    has_many :property_prototypes
    has_many :properties, through: :property_prototypes

    has_many :prototype_taxons, dependent: :destroy
    has_many :taxons, through: :prototype_taxons

    validates :name, presence: true
  end
end
