require 'spec_helper'

describe "exchanges:charge_unreturned_items" do
  let(:task) do
    Rake::Task['exchanges:charge_unreturned_items']
  end

  before do
    Rails.application.load_tasks
    task.reenable
  end

  subject { task }

  describe '#prerequisites' do
    it { expect(subject.prerequisites).to include("environment") }
  end

  before do
    @original_expedited_exchanges_pref = Solidus::Config[:expedited_exchanges]
    Solidus::Config[:expedited_exchanges] = true
    Solidus::StockItem.update_all(count_on_hand: 10)
  end

  after { Solidus::Config[:expedited_exchanges] = @original_expedited_exchanges_pref }

  context "there are no unreturned items" do
    it { expect { subject.invoke }.not_to change { Solidus::Order.count } }
  end

  context "there are return items in an intermediate return status" do
    let!(:order) { create(:shipped_order, line_items_count: 2) }
    let(:return_item_1) { build(:exchange_return_item, inventory_unit: order.inventory_units.first) }
    let(:return_item_2) { build(:exchange_return_item, inventory_unit: order.inventory_units.last) }
    let!(:rma) { create(:return_authorization, order: order, return_items: [return_item_1, return_item_2]) }
    let!(:tax_rate) { create(:tax_rate, zone: order.tax_zone, tax_category: return_item_2.exchange_variant.tax_category) }
    before do
      rma.save!
      Solidus::Shipment.last.ship!
      return_item_1.lost!
      return_item_2.give!
      Timecop.travel (Solidus::Config[:expedited_exchanges_days_window] + 1).days
    end
    after { Timecop.return }
    it { expect { subject.invoke }.not_to change { Solidus::Order.count } }
  end

  context "there are unreturned items" do
    let!(:order) { create(:shipped_order, line_items_count: 2) }
    let(:return_item_1) { build(:exchange_return_item, inventory_unit: order.inventory_units.first) }
    let(:return_item_2) { build(:exchange_return_item, inventory_unit: order.inventory_units.last) }
    let!(:rma) { create(:return_authorization, order: order, return_items: [return_item_1, return_item_2]) }
    let!(:tax_rate) { create(:tax_rate, zone: order.tax_zone, tax_category: return_item_2.exchange_variant.tax_category) }

    before do
      rma.save!
      Solidus::Shipment.last.ship!
      return_item_1.receive!
      Timecop.travel travel_time
    end

    after { Timecop.return }

    context "fewer than the config allowed days have passed" do
      let(:travel_time) { (Solidus::Config[:expedited_exchanges_days_window] - 1).days }

      it "does not create a new order" do
        expect { subject.invoke }.not_to change { Solidus::Order.count }
      end
    end

    context "more than the config allowed days have passed" do

      let(:travel_time) { (Solidus::Config[:expedited_exchanges_days_window] + 1).days }

      it "creates a new completed order" do
        expect { subject.invoke }.to change { Solidus::Order.count }
        expect(Solidus::Order.last).to be_completed
      end

      it "sets frontend_viewable to false" do
        subject.invoke
        expect(Solidus::Order.last).not_to be_frontend_viewable
      end

      it "moves the shipment for the unreturned items to the new order" do
        subject.invoke
        new_order = Solidus::Order.last
        expect(new_order.shipments.count).to eq 1
        expect(return_item_2.reload.exchange_shipment.order).to eq Solidus::Order.last
      end

      it "creates line items on the order for the unreturned items" do
        subject.invoke
        expect(Solidus::Order.last.line_items.map(&:variant)).to eq [return_item_2.exchange_variant]
      end

      it "associates the exchanges inventory units with the new line items" do
        subject.invoke
        expect(return_item_2.reload.exchange_inventory_unit.try(:line_item).try(:order)).to eq Solidus::Order.last
      end

      it "uses the credit card from the previous order" do
        subject.invoke
        new_order = Solidus::Order.last
        expect(new_order.credit_cards).to be_present
        expect(new_order.credit_cards.first).to eq order.valid_credit_cards.first
      end

      context "payments" do
        it "authorizes the order for the full amount of the unreturned items including taxes" do
          expect { subject.invoke }.to change { Solidus::Payment.count }.by(1)
          new_order = Solidus::Order.last
          expected_amount = return_item_2.reload.exchange_variant.price + new_order.additional_tax_total + new_order.included_tax_total + new_order.shipment_total
          expect(new_order.total).to eq expected_amount
          payment = new_order.payments.first
          expect(payment.amount).to eq expected_amount
          expect(new_order.item_total).to eq return_item_2.reload.exchange_variant.price
        end

        context "auto_capture_exchanges is true" do
          before do
            @original_auto_capture_exchanges = Solidus::Config[:auto_capture_exchanges]
            Solidus::Config[:auto_capture_exchanges] = true
          end

          after { Solidus::Config[:auto_capture_exchanges] = @original_auto_capture_exchanges }

          it 'creates a pending payment' do
            expect { subject.invoke }.to change { Solidus::Payment.count }.by(1)
            payment = Solidus::Payment.last
            expect(payment).to be_completed
          end
        end

        context "auto_capture_exchanges is false" do
          before do
            @original_auto_capture_exchanges = Solidus::Config[:auto_capture_exchanges]
            Solidus::Config[:auto_capture_exchanges] = false
          end

          after { Solidus::Config[:auto_capture_exchanges] = @original_auto_capture_exchanges }

          it 'captures payment' do
            expect { subject.invoke }.to change { Solidus::Payment.count }.by(1)
            payment = Solidus::Payment.last
            expect(payment).to be_pending
          end
        end
      end

      it "does not attempt to create a new order for the item more than once" do
        subject.invoke
        subject.reenable
        expect { subject.invoke }.not_to change { Solidus::Order.count }
      end

      it "associates the store of the original order with the exchange order" do
        store = order.store
        expect(Solidus::Order).to receive(:create!).once.with(hash_including({store_id: store.id})).and_call_original
        subject.invoke
      end

      it 'approves the order' do
        subject.invoke
        new_order = Solidus::Order.last
        expect(new_order).to be_approved
        expect(new_order.is_risky?).to eq false
        expect(new_order.approver_name).to eq "Solidus::UnreturnedItemCharger"
        expect(new_order.approver).to be nil
      end

      context "there is no card from the previous order" do
        let!(:credit_card) { create(:credit_card, user: order.user, default: true, gateway_customer_profile_id: "BGS-123") }
        before { allow_any_instance_of(Solidus::Order).to receive(:valid_credit_cards) { [] } }

        it "attempts to use the user's default card" do
          expect { subject.invoke }.to change { Solidus::Payment.count }.by(1)
          new_order = Solidus::Order.last
          expect(new_order.credit_cards).to be_present
          expect(new_order.credit_cards.first).to eq credit_card
        end
      end

      context "it is unable to authorize the credit card" do
        before { allow_any_instance_of(Solidus::Payment).to receive(:authorize!).and_raise(RuntimeError) }

        it "raises an error with the order" do
          expect { subject.invoke }.to raise_error(Solidus::ChargeUnreturnedItemsFailures)
        end
      end

      context "the exchange inventory unit is not shipped" do
        before { return_item_2.reload.exchange_inventory_unit.update_columns(state: "on hand") }
        it "does not create a new order" do
          expect { subject.invoke }.not_to change { Solidus::Order.count }
        end
      end

      context "the exchange inventory unit has been returned" do
        before { return_item_2.reload.exchange_inventory_unit.update_columns(state: "returned") }
        it "does not create a new order" do
          expect { subject.invoke }.not_to change { Solidus::Order.count }
        end
      end

      context 'rma for unreturned exchanges' do
        context 'config to not create' do
          before { Solidus::Config[:create_rma_for_unreturned_exchange] = false }

          it 'does not create rma' do
            expect { subject.invoke }.not_to change { Solidus::ReturnAuthorization.count }
          end
        end

        context 'config to create' do
          before do
            Solidus::Config[:create_rma_for_unreturned_exchange] = true
          end

          it 'creates with return items' do
            expect { subject.invoke }.to change { Solidus::ReturnAuthorization.count }
            rma = Solidus::ReturnAuthorization.last

            expect(rma.return_items.all?(&:awaiting?)).to be true
          end
        end
      end
    end
  end
end
