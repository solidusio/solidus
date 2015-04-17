module Spree
  class TransferItem < ActiveRecord::Base
    belongs_to :stock_transfer
    belongs_to :variant

    validates_presence_of :stock_transfer, :variant
    validates :expected_quantity, numericality: { greater_than: 0 }
    validates :received_quantity, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: :expected_quantity }

    scope :received, -> { where('received_quantity > 0') }
    scope :fully_received, -> { where('expected_quantity = received_quantity') }

  end
end
