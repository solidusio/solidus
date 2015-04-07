module Spree
  class TransferItem < ActiveRecord::Base
    belongs_to :stock_transfer
    belongs_to :variant

    validates_presence_of :stock_transfer, :variant

    scope :received, -> { where('expected_quantity = received_quantity') }

  end
end
