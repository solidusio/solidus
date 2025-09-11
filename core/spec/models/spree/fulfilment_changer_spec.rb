# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::FulfilmentChanger do
  let(:variant) { create(:variant) }
  let(:track_inventory) { true }

  let!(:order) do
    create(
      :completed_order_with_totals,
      line_items_attributes: [
        {
          quantity: current_shipment_inventory_unit_count,
          variant:
        }
      ]
    )
  end

  let(:current_shipment) { order.shipments.first }
  let!(:desired_shipment) { order.shipments.create!(stock_location: desired_stock_location) }
  let(:desired_stock_location) { current_shipment.stock_location }

  let(:shipment_splitter) do
    described_class.new(
      current_shipment:,
      desired_shipment:,
      variant:,
      quantity:,
      track_inventory:
    )
  end

  shared_examples_for "moves inventory units between shipments" do
    it "adds the desired inventory units to the desired shipment" do
      expect { subject }.to change { desired_shipment.inventory_units.length }.by(quantity)
    end

    it "removes the desired inventory units from the current shipment" do
      expect { subject }.to change { current_shipment.inventory_units.length }.by(-quantity)
    end
  end

  shared_examples_for "recalculates shipping costs and order totals" do
    it "recalculates shipping costs for the current shipment" do
      expect(current_shipment).to receive(:refresh_rates)
      subject
    end

    it "recalculates shipping costs for the new shipment" do
      expect(desired_shipment).to receive(:refresh_rates)
      subject
    end

    it "updates order totals" do
      original_total = order.total
      original_shipment_total = order.shipment_total

      expect { subject }
        .to change { order.total }.from(original_total).to(original_total + original_shipment_total)
        .and change { order.shipment_total }.by(original_shipment_total)
    end
  end

  shared_examples_for "completes transfer to another stock location without tracking inventory changes" do
    context "when transferring to another stock location" do
      let(:desired_stock_location) { create(:stock_location) }

      it "is marked as a successful transfer" do
        expect(subject).to be true
      end

      it "does not stock in the current stock location" do
        expect { subject }.not_to change { current_shipment.stock_location.count_on_hand(variant) }
      end

      it "does not unstock the desired stock location" do
        expect { subject }.not_to change { desired_shipment.stock_location.count_on_hand(variant) }
      end
    end
  end

  shared_examples_for "properly manages inventory units" do
    let(:stock_item) { variant.stock_items.find_by!(stock_location: current_shipment.stock_location) }

    context "when there are backordered inventory units" do
      let(:backordered_units_count) { 1 }

      before do
        current_shipment.inventory_units.limit(backordered_units_count).update!(state: :backordered)
      end

      context "when the stock is zero or negative" do
        before do
          stock_item.update_column(:count_on_hand, -backordered_units_count)
        end

        it "doesn't change inventory units state" do
          expect { subject }
            .not_to change { order.inventory_units.map(&:state).sort }
            .from(%w[backordered on_hand])
        end
      end

      context "when backordered items can become on hand" do
        before do
          stock_item.update_column(:count_on_hand, backordered_units_count)
        end

        it "makes all inventory units on hand" do
          expect { subject }
            .to change { order.inventory_units.map(&:state).sort }
            .from(%w[backordered on_hand]).to(%w[on_hand on_hand])
        end
      end
    end

    context "when all inventory units are on hand" do
      before do
        current_shipment.inventory_units.update_all(state: :on_hand)
      end

      context "when the stock is negative" do
        before do
          stock_item.update_column(:count_on_hand, -1)
        end

        it "doesn't change the order inventory units state" do
          expect { subject }.not_to change { order.inventory_units.map(&:state).sort }
        end
      end
    end

    context "when the stock location is empty" do
      before { stock_item.update_column(:count_on_hand, 0) }

      it "doesn't change the order inventory units state" do
        expect { subject }.not_to change { order.inventory_units.map(&:state).sort }
      end
    end
  end

  subject { shipment_splitter.run! }

  before do
    variant.stock_items.first.update_column(:count_on_hand, 100)
  end

  context "when tracking inventory (default behavior)" do
    let(:current_shipment_inventory_unit_count) { 2 }
    let(:quantity) { 1 }

    it_behaves_like "moves inventory units between shipments"
    it_behaves_like "properly manages inventory units"

    context "and we're only moving some backordered units" do
      let(:stock_item) { variant.stock_items.find_by!(stock_location: current_shipment.stock_location) }
      let(:current_shipment_inventory_unit_count) { 10 }
      let(:quantity) { 4 }

      before do
        current_shipment.inventory_units.limit(6).update!(state: :backordered)
        stock_item.update_column(:count_on_hand, -6)
      end

      it_behaves_like "moves inventory units between shipments"

      it "only removes the desired quantity of backordered items" do
        subject

        expect(current_shipment.inventory_units.on_hand.count).to eq(4)
        expect(current_shipment.inventory_units.backordered.count).to eq(2)

        expect(desired_shipment.inventory_units.on_hand.count).to eq(0)
        expect(desired_shipment.inventory_units.backordered.count).to eq(4)
      end
    end
  end

  context "when tracking inventory is not set (same as false)" do
    let(:current_shipment_inventory_unit_count) { 2 }
    let(:quantity) { 1 }
    let(:track_inventory) { nil }

    it_behaves_like "moves inventory units between shipments"
    it_behaves_like "recalculates shipping costs and order totals"
    it_behaves_like "completes transfer to another stock location without tracking inventory changes"
  end

  context "when not tracking inventory" do
    let(:current_shipment_inventory_unit_count) { 2 }
    let(:quantity) { 1 }
    let(:track_inventory) { false }

    it_behaves_like "moves inventory units between shipments"
    it_behaves_like "completes transfer to another stock location without tracking inventory changes"
  end

  context "when the current shipment has enough inventory units" do
    let(:current_shipment_inventory_unit_count) { 2 }
    let(:quantity) { 1 }

    it_behaves_like "moves inventory units between shipments"
    it_behaves_like "recalculates shipping costs and order totals"

    context "when transferring to another stock location" do
      let(:desired_stock_location) { create(:stock_location) }
      let!(:stock_item) do
        variant.stock_items.find_or_create_by!(
          stock_location: desired_stock_location,
          variant:
        )
      end

      before do
        stock_item.set_count_on_hand(desired_count_on_hand)
        stock_item.update(backorderable: false)
      end

      context "when the other stock location has enough stock" do
        let(:desired_count_on_hand) { 2 }

        it "is marked as a successful transfer" do
          expect(subject).to be true
        end

        it "stocks the current stock location back up" do
          expect { subject }.to change { current_shipment.stock_location.count_on_hand(variant) }.by(quantity)
        end

        it "unstocks the desired stock location" do
          expect { subject }.to change { desired_shipment.stock_location.count_on_hand(variant) }.by(-quantity)
        end

        context "when the order is not completed" do
          before do
            allow(order).to receive(:completed?).and_return(false)
          end

          it "does not stock the current stock location back up" do
            expect { subject }.not_to change { current_shipment.stock_location.count_on_hand(variant) }
          end

          it "does not unstock the desired location" do
            expect { subject }.not_to change { stock_item.count_on_hand }
          end
        end
      end

      context "when the desired stock location can only partially fulfil the quantity" do
        let(:current_shipment_inventory_unit_count) { 10 }
        let(:quantity) { 7 }
        let(:desired_count_on_hand) { 5 }

        before do
          stock_item.update(backorderable: true)
        end

        it "restocks seven at the original stock location" do
          expect { subject }.to change { current_shipment.stock_location.count_on_hand(variant) }.by(7)
        end

        it "unstocks seven at the desired stock location" do
          expect { subject }.to change { desired_shipment.stock_location.count_on_hand(variant) }.by(-7)
        end

        it "creates a shipment with the correct number of on hand and backordered units" do
          subject
          expect(desired_shipment.inventory_units.on_hand.count).to eq(5)
          expect(desired_shipment.inventory_units.backordered.count).to eq(2)
        end

        context "when the desired stock location already has a backordered units" do
          let(:desired_count_on_hand) { -1 }

          it "restocks seven at the original stock location" do
            expect { subject }.to change { current_shipment.stock_location.count_on_hand(variant) }.by(7)
          end

          it "unstocks seven at the desired stock location" do
            expect { subject }.to change { desired_shipment.stock_location.count_on_hand(variant) }.by(-7)
          end

          it "creates a shipment with the correct number of on hand and backordered units" do
            subject
            expect(desired_shipment.inventory_units.on_hand.count).to eq(0)
            expect(desired_shipment.inventory_units.backordered.count).to eq(7)
          end
        end

        context "when the original shipment has on hand and backordered units" do
          before do
            current_shipment.inventory_units.limit(6).update_all(state: :backordered)
          end

          it "removes the backordered items first" do
            subject
            expect(current_shipment.inventory_units.backordered.count).to eq(0)
            expect(current_shipment.inventory_units.on_hand.count).to eq(3)
          end
        end

        context "when the original shipment had some backordered units" do
          let(:current_stock_item) { current_shipment.stock_location.stock_items.find_by(variant:) }
          let(:desired_stock_item) { desired_shipment.stock_location.stock_items.find_by(variant:) }
          let(:backordered_units) { 6 }

          before do
            current_shipment.inventory_units.limit(backordered_units).update_all(state: :backordered)
            current_stock_item.set_count_on_hand(-backordered_units)
          end

          it "restocks four at the original stock location" do
            expect { subject }.to change { current_stock_item.reload.count_on_hand }.from(-backordered_units).to(1)
          end

          it "unstocks five at the desired stock location" do
            expect { subject }.to change { desired_stock_item.reload.count_on_hand }.from(5).to(-2)
          end

          it "creates a shipment with the correct number of on hand and backordered units" do
            subject
            expect(desired_shipment.inventory_units.on_hand.count).to eq(5)
            expect(desired_shipment.inventory_units.backordered.count).to eq(2)
          end
        end
      end

      context "when the other stock location does not have enough stock" do
        let(:desired_count_on_hand) { 0 }

        it "is not successful" do
          expect(subject).to be false
        end

        it "has an activemodel error hash" do
          subject
          expect(shipment_splitter.errors.messages).to eq(desired_shipment: ["not enough stock in desired stock location"])
        end
      end
    end

    context "when the quantity to transfer is not positive" do
      let(:quantity) { 0 }

      it "is not successful" do
        expect(subject).to be false
      end

      it "has an activemodel error hash" do
        subject
        expect(shipment_splitter.errors.messages).to eq(quantity: ["must be greater than 0"])
      end
    end

    context "when the desired shipment is identical to the current shipment" do
      let(:desired_shipment) { current_shipment }

      it "is not successful" do
        expect(subject).to be false
      end

      it "has an activemodel error hash" do
        subject
        expect(shipment_splitter.errors.messages).to eq(desired_shipment: ["can not be same as current shipment"])
      end
    end

    context "when the desired shipment has no stock location" do
      let(:desired_stock_location) { nil }

      it "is not successful" do
        expect(subject).to be false
      end

      it "has an activemodel error hash" do
        subject
        expect(shipment_splitter.errors.messages).to eq(desired_stock_location: ["can't be blank"])
      end
    end

    context "when the current shipment has been shipped already" do
      let(:order) do
        create(
          :shipped_order,
          line_items_attributes: [
            {
              quantity: current_shipment_inventory_unit_count,
              variant:
            }
          ]
        )
      end

      it "is not successful" do
        expect(subject).to be false
      end

      it "has an activemodel error hash" do
        subject
        expect(shipment_splitter.errors.messages).to eq(current_shipment: ["has already been shipped"])
      end
    end
  end

  context "when the current shipment is emptied out by the transfer" do
    let(:current_shipment_inventory_unit_count) { 30 }
    let(:quantity) { current_shipment_inventory_unit_count }

    it_behaves_like "moves inventory units between shipments"

    it "removes the current shipment" do
      expect { subject }.to change { Spree::Shipment.count }.by(-1)
    end
  end

  context "when the desired shipment is not yet persisted" do
    let(:current_shipment_inventory_unit_count) { 2 }
    let(:quantity) { 1 }

    let(:desired_shipment) { order.shipments.build(stock_location: current_shipment.stock_location) }

    it_behaves_like "moves inventory units between shipments"
    it_behaves_like "properly manages inventory units"

    context "if the desired shipment is invalid" do
      let(:desired_shipment) { order.shipments.build(stock_location_id: 99_999_999) }

      it "is not successful" do
        expect(subject).to be false
      end

      it "has an activemodel error hash" do
        subject
        expect(shipment_splitter.errors.messages).to eq(desired_stock_location: ["can't be blank"])
      end
    end
  end
end
