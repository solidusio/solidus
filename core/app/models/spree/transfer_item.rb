module Spree
  class TransferItem < ActiveRecord::Base
    belongs_to :stock_transfer
    belongs_to :variant

    validate :stock_availability, if: :check_stock?
    validates_presence_of :stock_transfer, :variant
    validates_uniqueness_of :variant_id, scope: :stock_transfer_id
    validates :expected_quantity, numericality: { greater_than: 0 }
    validates :received_quantity, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: :expected_quantity }

    scope :received, -> { where('received_quantity > 0') }
    scope :fully_received, -> { where('expected_quantity = received_quantity') }
    scope :partially_received, -> { received.where('expected_quantity > received_quantity') }

    before_destroy :ensure_stock_transfer_not_finalized
    before_validation :ensure_stock_transfer_not_closed
    before_update :prevent_expected_quantity_update_stock_transfer_finalized

    private

    def ensure_stock_transfer_not_closed
      if stock_transfer_closed?
        errors.add(:base, Spree.t('errors.messages.cannot_modify_transfer_item_closed_stock_transfer'))
      end
    end

    def ensure_stock_transfer_not_finalized
      unless stock_transfer.finalizable?
        errors.add(:base, Spree.t('errors.messages.cannot_delete_transfer_item_with_finalized_stock_transfer'))
        return false
      end
    end

    def prevent_expected_quantity_update_stock_transfer_finalized
      if expected_quantity_changed? && stock_transfer.finalized?
        errors.add(:base, Spree.t('errors.messages.cannot_update_expected_transfer_item_with_finalized_stock_transfer'))
        return false
      end
    end

    def stock_availability
      stock_item = variant.stock_items.find_by(stock_location: stock_transfer.source_location)
      if stock_item.nil? || stock_item.count_on_hand < expected_quantity
        errors.add(:base, Spree.t('errors.messages.transfer_item_insufficient_stock'))
      end
    end

    def stock_transfer_closed?
      stock_transfer.closed?
    end

    def check_stock?
      !stock_transfer_closed? && stock_transfer.source_location.check_stock_on_transfer?
    end
  end
end
