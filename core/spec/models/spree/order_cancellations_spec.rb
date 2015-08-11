require 'spec_helper'

describe Spree::OrderCancellations do
  describe "#short_ship" do
    subject { Spree::OrderCancellations.new(order).short_ship([inventory_unit]) }

    let(:order) { create(:order_ready_to_ship, line_items_count: 1) }
    let(:inventory_unit) { order.inventory_units.first }
    let(:shipment) { inventory_unit.shipment }

    it "creates a UnitCancel record" do
      expect { subject }.to change { Spree::UnitCancel.count }.by(1)

      unit_cancel = Spree::UnitCancel.last
      expect(unit_cancel.inventory_unit).to eq inventory_unit
      expect(unit_cancel.reason).to eq Spree::UnitCancel::SHORT_SHIP
    end

    it "cancels the inventory unit" do
      expect { subject }.to change { inventory_unit.state }.to "canceled"
    end

    it "updates the shipment.state" do
      expect { subject }.to change { shipment.reload.state }.from('ready').to('shipped')
    end

    it "updates the order.shipment_state" do
      expect { subject }.to change { order.shipment_state }.from('ready').to('shipped')
    end

    it "adjusts the order" do
      expect { subject }.to change { order.total }.by(-10.0)
    end

    it "sends a cancellation email" do
      mail_double = double
      expect(Spree::OrderMailer).to receive(:inventory_cancellation_email).with(order, [inventory_unit]).and_return(mail_double)
      expect(mail_double).to receive(:deliver_later)
      subject
    end

    context "when send_cancellation_mailer is false" do
      subject { Spree::OrderCancellations.new(order).short_ship([inventory_unit]) }

      before do
        @original_send_boolean = Spree::OrderCancellations.send_cancellation_mailer
        Spree::OrderCancellations.send_cancellation_mailer = false
      end

      after { Spree::OrderCancellations.send_cancellation_mailer = @original_send_boolean }

      it "does not send a cancellation email" do
        expect(Spree::OrderMailer).not_to receive(:inventory_cancellation_email)
        subject
      end
    end

    context "with a who" do
      subject { order.cancellations.short_ship([inventory_unit], whodunnit: 'some automated system') }

      let(:user) { order.user }

      it "sets the user on the UnitCancel" do
        expect { subject }.to change { Spree::UnitCancel.count }.by(1)
        expect(Spree::UnitCancel.last.created_by).to eq("some automated system")
      end
    end

    context "when rounding is required" do
      let(:order) { create(:order_ready_to_ship, line_items_count: 1, line_items_price: 0.83) }
      let(:line_item) { order.line_items.first }
      let(:inventory_unit_1) { line_item.inventory_units[0] }
      let(:inventory_unit_2) { line_item.inventory_units[1] }

      before do
        order.contents.add(line_item.variant)
        line_item.reload

        # make the total $1.67 so it divides unevenly
        Spree::Adjustment.tax.create!(
          order: order,
          adjustable: line_item,
          amount: 0.01,
          label: 'some fake tax',
          finalized: true
        )
        order.update!
      end

      it "generates the correct total amount" do
        order.cancellations.short_ship([inventory_unit_1])
        order.cancellations.short_ship([inventory_unit_2])
        expect(line_item.adjustments.non_tax.sum(:amount)).to eq -1.67
        expect(line_item.total).to eq 0
      end
    end

    describe 'short_ship_tax_notifier' do
      context 'when present' do
        let(:short_ship_tax_notifier) { double }

        before do
          @old_notifier = Spree::OrderCancellations.short_ship_tax_notifier
          Spree::OrderCancellations.short_ship_tax_notifier = short_ship_tax_notifier
        end
        after do
          Spree::OrderCancellations.short_ship_tax_notifier = @old_notifier
        end

        it 'calls the short_ship_tax_notifier' do
          expect(short_ship_tax_notifier).to receive(:call) do |unit_cancels|
            expect(unit_cancels.map(&:inventory_unit)).to match_array([inventory_unit])
          end

          order.cancellations.short_ship([inventory_unit])
        end
      end
    end
  end
end
