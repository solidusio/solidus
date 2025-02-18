# frozen_string_literal: true

module Spree
  class StockMovement < Spree::Base
    belongs_to :stock_item, class_name: "Spree::StockItem", inverse_of: :stock_movements, optional: true
    belongs_to :originator, polymorphic: true, optional: true
    has_one :variant, through: :stock_item

    after_create :update_stock_item_quantity

    validates :stock_item, presence: true
    validates :quantity, presence: true

    scope :recent, -> { order(created_at: :desc) }

    self.allowed_ransackable_associations = %w[variant]
    self.allowed_ransackable_attributes = ["quantity"]

    def readonly?
      !new_record?
    end

    private

    def update_stock_item_quantity
      return unless stock_item.should_track_inventory?
      stock_item.adjust_count_on_hand quantity
    end
  end
end
