# frozen_string_literal: true

RSpec.shared_examples "shipping methods are assigned" do
  context "given a shipping method" do
    let(:shipping_method) { create(:shipping_method) }

    it "assigns the shipping method when created" do
      expect(
        create(
          factory,
          shipping_method:
        ).shipments.map(&:shipping_method)
      ).to all(eq(shipping_method))
    end

    it "assigns the shipping method when built" do
      expect(
        build(
          factory,
          shipping_method:
        ).shipments.map(&:shipping_method)
      ).to all(eq(shipping_method))
    end
  end
end

RSpec.shared_examples "an order with line items factory" do |expected_order_state, expected_inventory_unit_state|
  # This factory cannot be built correctly because Shipment#set_up_inventory
  # requires records to be saved.
  context "when created" do
    let(:stock_location) { create(:stock_location) }
    let(:first_variant) { create(:variant) }
    let(:second_variant) { create(:variant) }
    let(:shipping_method) { create(:shipping_method) }
    let(:order) do
      create(
        factory,
        stock_location:,
        line_items_attributes: [
          { variant: first_variant, quantity: 1, price: 1 },
          { variant: second_variant, quantity: 2, price: 2 }
        ],
        shipment_cost: 3,
        shipping_method:
      )
    end

    it "has the expected attributes" do
      aggregate_failures "for line items" do
        expect(order.line_items.count).to eq 2
        expect(order.line_items[0]).to have_attributes(
          quantity: 1,
          price: 1.0
        )
        expect(order.line_items[1]).to have_attributes(
          price: 2.0,
          quantity: 2
        )
      end

      aggregate_failures "for shipments" do
        expect(order.shipments.count).to eq 1
        expect(order.shipments[0]).to have_attributes(
          amount: 3.0,
          stock_location:
        )

        expect(order.shipments[0].shipping_method).to eq(shipping_method)

        # Explicitly order by line item id, because otherwise these can be in
        # an arbitrary order.
        inventory_units = order.shipments[0].inventory_units.sort_by(&:line_item_id)

        expect(inventory_units.count).to eq(3)
        expect(inventory_units[0]).to have_attributes(
          order:,
          shipment: order.shipments[0],
          line_item: order.line_items[0],
          variant: order.line_items[0].variant,
          state: expected_inventory_unit_state
        )
        expect(inventory_units[1]).to have_attributes(
          order:,
          shipment: order.shipments[0],
          line_item: order.line_items[1],
          variant: order.line_items[1].variant,
          state: expected_inventory_unit_state
        )
        expect(inventory_units[2]).to have_attributes(
          order:,
          shipment: order.shipments[0],
          line_item: order.line_items[1],
          variant: order.line_items[1].variant,
          state: expected_inventory_unit_state
        )
      end

      expect(order).to have_attributes(
        item_total: 5.0,
        ship_total: 3.0,
        total: 8.0,
        state: expected_order_state
      )
    end
  end

  context 'when shipments should be taxed' do
    let!(:ship_address) { create(:address) }
    let!(:tax_zone) { create(:global_zone) } # will include the above address
    let!(:tax_rate) { create(:tax_rate, amount: 0.10, zone: tax_zone, tax_categories: [tax_category]) }

    let(:tax_category) { create(:tax_category) }
    let(:shipping_method) { create(:shipping_method, tax_category:, zones: [tax_zone]) }

    it 'shipments get a tax adjustment' do
      order = create(factory, ship_address:, shipping_method:)
      shipment = order.shipments[0]

      expect(shipment.additional_tax_total).to be > 0
    end
  end
end

RSpec.shared_examples 'supplied completed_at is respected' do
  context 'when passed a completed_at timestamp' do
    let(:completed_at) { 2.days.ago }
    let(:order) { create(factory, completed_at:) }

    it 'respects the timestamp' do
      expect(order.completed_at).to be_within(5.seconds).of(completed_at)
    end
  end

  context 'when no completed_at timestamp is passed' do
    let(:order) { create(factory) }

    it 'defaults to the current time' do
      expect(order.completed_at).to be_within(2.seconds).of(Time.current)
    end
  end
end
