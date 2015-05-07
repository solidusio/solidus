module Spree
  class StockTransfer < Spree::Base
    has_many :stock_movements, :as => :originator
    has_many :transfer_items

    belongs_to :created_by, :class_name => 'Spree::User'
    belongs_to :closed_by, :class_name => 'Spree::User'
    belongs_to :source_location, :class_name => 'Spree::StockLocation'
    belongs_to :destination_location, :class_name => 'Spree::StockLocation'

    make_permalink field: :number, prefix: 'T'

    def closed?
      closed_at.present?
    end

    def to_param
      number
    end

    def ship(tracking_number:, shipped_at:)
      update_attributes!(tracking_number: tracking_number, shipped_at: shipped_at)
    end

    def received_item_count
      transfer_items.sum(:received_quantity)
    end

    def expected_item_count
      transfer_items.sum(:expected_quantity)
    end

    def source_movements
      stock_movements.joins(:stock_item)
        .where('spree_stock_items.stock_location_id' => source_location_id)
    end

    def destination_movements
      stock_movements.joins(:stock_item)
        .where('spree_stock_items.stock_location_id' => destination_location_id)
    end

    def transfer(source_location, destination_location, variants)
      transaction do
        variants.each_pair do |variant, quantity|
          source_location.unstock(variant, quantity, self) if source_location
          destination_location.restock(variant, quantity, self)

          self.source_location = source_location
          self.destination_location = destination_location
          self.save!
        end
      end
    end

    def receive(destination_location, variants)
      transfer(nil, destination_location, variants)
    end
  end
end
