require 'spec_helper'

describe Spree::OrderContents do
  let(:order) { Spree::Order.create }
  let(:variant) { create(:variant) }

  subject { described_class.new(order) }

  context "#add" do
    context 'given quantity is not explicitly provided' do
      it 'should add one line item' do
        line_item = subject.add(variant)
        line_item.quantity.should == 1
        order.line_items.size.should == 1
      end
    end

    context 'given a shipment' do
      it "ensure shipment calls update_amounts instead of order calling ensure_updated_shipments" do
        shipment = create(:shipment)
        expect(subject.order).to_not receive(:ensure_updated_shipments)
        expect(shipment).to receive(:update_amounts)
        subject.add(variant, 1, nil, shipment)
      end
    end

    context 'not given a shipment' do
      it "ensures updated shipments" do
        expect(subject.order).to receive(:ensure_updated_shipments)
        subject.add(variant)
      end
    end

    it 'should add line item if one does not exist' do
      line_item = subject.add(variant, 1)
      line_item.quantity.should == 1
      order.line_items.size.should == 1
    end

    it 'should update line item if one exists' do
      subject.add(variant, 1)
      line_item = subject.add(variant, 1)
      line_item.quantity.should == 2
      order.line_items.size.should == 1
    end

    it "should update order totals" do
      order.item_total.to_f.should == 0.00
      order.total.to_f.should == 0.00

      subject.add(variant, 1)

      order.item_total.to_f.should == 19.99
      order.total.to_f.should == 19.99
    end

    context "running promotions" do
      let(:promotion) { create(:promotion) }
      let(:calculator) { Spree::Calculator::FlatRate.new(:preferred_amount => 10) }

      shared_context "discount changes order total" do
        before { subject.add(variant, 1) }
        it { expect(subject.order.total).not_to eq variant.price }
      end

      context "one active order promotion" do
        let!(:action) { Spree::Promotion::Actions::CreateAdjustment.create(promotion: promotion, calculator: calculator) }

        it "creates valid discount on order" do
          subject.add(variant, 1)
          expect(subject.order.adjustments.to_a.sum(&:amount)).not_to eq 0
        end

        include_context "discount changes order total"
      end

      context "one active line item promotion" do
        let!(:action) { Spree::Promotion::Actions::CreateItemAdjustments.create(promotion: promotion, calculator: calculator) }

        it "creates valid discount on order" do
          subject.add(variant, 1)
          expect(subject.order.line_item_adjustments.to_a.sum(&:amount)).not_to eq 0
        end

        include_context "discount changes order total"
      end
    end

    pending "what if validation fails"
  end

  context "#remove" do
    context "given an invalid variant" do
      it "raises an exception" do
        expect {
          subject.remove(variant, 1)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'given quantity is not explicitly provided' do
      it 'should remove one line item' do
        line_item = subject.add(variant, 3)
        subject.remove(variant)

        line_item.reload.quantity.should == 2
      end
    end

    context 'given a shipment' do
      it "ensure shipment calls update_amounts instead of order calling ensure_updated_shipments" do
        line_item = subject.add(variant, 1)
        shipment = create(:shipment)
        expect(subject.order).to_not receive(:ensure_updated_shipments)
        expect(shipment).to receive(:update_amounts)
        subject.remove(variant, 1, shipment)
      end
    end

    context 'not given a shipment' do
      it "ensures updated shipments" do
        line_item = subject.add(variant, 1)
        expect(subject.order).to receive(:ensure_updated_shipments)
        subject.remove(variant)
      end
    end

    it 'should reduce line_item quantity if quantity is less the line_item quantity' do
      line_item = subject.add(variant, 3)
      subject.remove(variant, 1)

      line_item.reload.quantity.should == 2
    end

    it 'should remove line_item if quantity matches line_item quantity' do
      subject.add(variant, 1)
      subject.remove(variant, 1)

      order.reload.find_line_item_by_variant(variant).should be_nil
    end

    it "should update order totals" do
      order.item_total.to_f.should == 0.00
      order.total.to_f.should == 0.00

      subject.add(variant,2)

      order.item_total.to_f.should == 39.98
      order.total.to_f.should == 39.98

      subject.remove(variant,1)
      order.item_total.to_f.should == 19.99
      order.total.to_f.should == 19.99
    end
  end

  context "update cart" do
    let!(:shirt) { subject.add variant, 1 }

    let(:params) do
      { line_items_attributes: {
        "0" => { id: shirt.id, quantity: 3 }
      } }
    end

    it "changes item quantity" do
      subject.update_cart params
      expect(shirt.reload.quantity).to eq 3
    end

    it "updates order totals" do
      expect {
        subject.update_cart params
      }.to change { subject.order.total }
    end

    context "submits item quantity 0" do
      let(:params) do
        { line_items_attributes: {
          "0" => { id: shirt.id, quantity: 0 }
        } }
      end

      it "removes item from order" do
        expect {
          subject.update_cart params
        }.to change { subject.order.line_items.count }
      end
    end

    pending "what if validation fails"
    pending "destroy existing shipments when order is not in cart state"
  end

  context "completed order" do
    let(:order) { Spree::Order.create! state: 'complete', completed_at: Time.now }

    before { order.shipments.create! stock_location_id: variant.stock_location_ids.first }

    it "updates order payment state" do
      expect {
        subject.add variant
      }.to change { order.payment_state }

      order.payments.create! amount: order.total

      expect {
        subject.remove variant
      }.to change { order.payment_state }
    end
  end

  describe "#associate_user" do
    let(:order) { create(:order_with_line_items, created_by: nil, user: nil, email: nil) }
    let(:user)  { create(:user) }
    let(:override_email) { false }

    subject { described_class.new(order).associate_user(user, override_email) }

    it "associates the user" do
      expect { subject }.to change { order.reload.user }.to user
    end

    context "order email is already set" do
      before { order.update_attributes!(email: FactoryGirl.generate(:random_email)) }
      context "told to override the email" do
        let(:override_email) { true }
        it "copies the user's email" do
          expect { subject }.to change { order.reload.email }.to user.email
        end
      end
      context "not told to override the email" do
        let(:override_email) { false }
        it "leave the order's email intact" do
          expect { subject }.not_to change { order.reload.email }
        end
      end
    end

    context "order email is not yet set" do
      it "copies the user's email" do
        expect { subject }.to change { order.reload.email }.to user.email
      end
    end

    context "created_by is already set" do
      before { order.update_attributes!(created_by: create(:user)) }
      it "leaves the created_by intact" do
        expect { subject }.not_to change { order.reload.created_by }
      end
    end

    context "created_by is not yet set" do
      it "sets the user to be the created_by" do
        expect { subject }.to change { order.reload.created_by }.to user
      end
    end

    context "the order is invalid" do
      before do
        order.build_ship_address
        expect(order.ship_address).not_to be_valid
        expect(order).not_to be_valid
      end
      it "still saves the new user association" do
        expect { subject }.to change { order.reload.user }.to user
      end
    end

    it "attempts to re-activate promotions" do
      expect_any_instance_of(Spree::PromotionHandler::Cart).to receive(:activate)
      subject
    end

    it "reloads totals" do
      expect_any_instance_of(Spree::OrderContents).to receive(:reload_totals).twice
      subject
    end
  end

  describe "#merge" do
    let(:variant) { create(:variant) }
    let(:order_1) { Spree::Order.create! }
    let(:order_2) { Spree::Order.create! }

    it "destroys the other order" do
      order_1.contents.merge(order_2)
      lambda { order_2.reload }.should raise_error(ActiveRecord::RecordNotFound)
    end

    context "user is provided" do
      let(:user) { create(:user) }

      it "assigns user to new order" do
        order_1.contents.merge(order_2, user: user)
        expect(order_1.user).to eq user
      end
    end

    context "merging together two orders with line items for the same variant" do
      before do
        order_1.contents.add(variant, 1)
        order_2.contents.add(variant, 1)
      end

      specify do
        order_1.contents.merge(order_2)
        order_1.line_items.count.should == 1

        line_item = order_1.line_items.first
        line_item.quantity.should == 2
        line_item.variant_id.should == variant.id
      end
    end

    context "merging together two orders with different line items" do
      let(:variant_2) { create(:variant) }

      before do
        order_1.contents.add(variant, 1)
        order_2.contents.add(variant_2, 1)
      end

      specify do
        order_1.contents.merge(order_2)
        line_items = order_1.line_items
        line_items.count.should == 2

        expect(order_1.item_count).to eq 2
        expect(order_1.item_total).to eq line_items.map(&:amount).sum

        # No guarantee on ordering of line items, so we do this:
        line_items.pluck(:quantity).should =~ [1, 1]
        line_items.pluck(:variant_id).should =~ [variant.id, variant_2.id]
      end
    end
  end

  describe "#cancel" do
    let(:order) { create(:order, state: 'complete', completed_at: Time.now) }

    it "cancels the order" do
      expect do
        order.cancel
      end.to change { order.reload.state }.from('complete').to('canceled')
    end
  end
end
