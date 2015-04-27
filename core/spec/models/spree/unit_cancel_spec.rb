require 'spec_helper'

describe Spree::UnitCancel do
  let(:unit_cancel) { Spree::UnitCancel.create!(inventory_unit: inventory_unit, reason: Spree::UnitCancel::SHORT_SHIP) }
  let(:inventory_unit) { create(:inventory_unit) }

  describe '#adjust!' do
    subject { unit_cancel.adjust! }

    it "creates an adjustment with the correct attributes" do
      expect { subject }.to change{ Spree::Adjustment.count }.by(1)

      adjustment = Spree::Adjustment.last
      expect(adjustment.adjustable).to eq inventory_unit.line_item
      expect(adjustment.amount).to eq -10.0
      expect(adjustment.order).to eq inventory_unit.order
      expect(adjustment.label).to eq "Cancellation - Short Ship"
      expect(adjustment.eligible).to eq true
      expect(adjustment.state).to eq 'closed'
    end

    context "when an adjustment has already been created" do
      before { unit_cancel.adjust! }

      it "raises" do
        expect { subject }.to raise_error("Adjustment is already created")
      end
    end
  end

  describe '#compute_amount' do
    subject { unit_cancel.compute_amount(line_item) }

    let(:line_item) { inventory_unit.line_item }
    let!(:inventory_unit2) { create(:inventory_unit, line_item: inventory_unit.line_item) }

    context "all inventory on the line item are not canceled" do
      it "divides the line item total by the inventory units size" do
        expect(subject).to eq -5.0
      end
    end

    context "some inventory on the line item is canceled" do
      before { inventory_unit2.cancel! }

      it "divides the line item total by the uncanceled units size" do
        expect(subject).to eq -10.0
      end
    end

    context "it is called with a line item that doesnt belong to the inventory unit" do
      let(:line_item) { create(:line_item) }

      it "raises an error" do
        expect { subject }.to raise_error
      end
    end

    context "when exchanges are present" do
      let!(:order) { create(:order, ship_address: create(:address)) }
      let!(:product) { create(:product, price: 10.00) }
      let!(:variant) do
        create(:variant, price: 10, product: product, track_inventory: false)
      end
      let!(:shipping_method) { create(:free_shipping_method) }
      let(:exchange_variant) do
        create(:variant, product: variant.product, price: 10, track_inventory: false)
      end

      before do
        @old_expedited_exchanges_value = Spree::Config[:expedited_exchanges]
        Spree::Config[:expedited_exchanges] = true
      end
      after do
        Spree::Config[:expedited_exchanges] = @old_expedited_exchanges_value
      end

      # This sets up an order with one shipped inventory unit, one unshipped
      # inventory unit, and one unshipped exchange inventory unit.
      before do
        # Complete an order with 1 line item with quantity=2
        order.contents.add(variant, 2)
        order.contents.advance
        create(:payment, order: order, amount: order.total)
        order.complete!
        order.reload

        # Ship _one_ of the inventory units
        @shipment = order.shipments.first
        @shipped_inventory_unit = order.inventory_units[0]
        @unshipped_inventory_unit = order.inventory_units[1]
        order.shipping.ship(
          inventory_units: [@shipped_inventory_unit],
          stock_location: @shipment.stock_location,
          address: order.ship_address,
          shipping_method: @shipment.shipping_method,
        )

        # Create an expedited exchange for the shipped inventory unit.
        # This generates a new inventory unit attached to the existing line item.
        Spree::ReturnAuthorization.create!(
          order: order,
          stock_location: @shipment.stock_location,
          reason: create(:return_authorization_reason),
          return_items: [
            Spree::ReturnItem.new(
              inventory_unit: @shipped_inventory_unit,
              exchange_variant: exchange_variant,
            ),
          ],
        )
        @exchange_inventory_unit = order.inventory_units.reload[2]
      end

      context 'when canceling an unshipped inventory unit from the original order' do
        subject do
          unit_cancel.compute_amount(@unshipped_inventory_unit.line_item)
        end

        let(:unit_cancel) do
          Spree::UnitCancel.create!(
            inventory_unit: @unshipped_inventory_unit,
            reason: Spree::UnitCancel::SHORT_SHIP,
          )
        end

        it { is_expected.to eq(-10.00) }
      end

      context 'when canceling an unshipped exchange inventory unit' do
        subject do
          unit_cancel.compute_amount(@exchange_inventory_unit.line_item)
        end

        let(:unit_cancel) do
          Spree::UnitCancel.create!(
            inventory_unit: @exchange_inventory_unit,
            reason: Spree::UnitCancel::SHORT_SHIP,
          )
        end

        it { is_expected.to eq(-10.00) }
      end
    end
  end

end
