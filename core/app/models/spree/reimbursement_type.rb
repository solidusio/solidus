module Spree
  class ReimbursementType < ActiveRecord::Base
    include Spree::NamedType

    ORIGINAL = 'original'

    has_many :return_items
  end
end
