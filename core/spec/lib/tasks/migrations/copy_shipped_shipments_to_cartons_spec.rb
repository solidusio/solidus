require 'spec_helper'

describe 'spree:migrations:copy_shipped_shipments_to_cartons' do
  include_context(
    'rake',
    task_name: 'spree:migrations:copy_shipped_shipments_to_cartons:up',
    task_path: Spree::Core::Engine.root.join('lib/tasks/migrations/copy_shipped_shipments_to_cartons.rake'),
  )

  describe 'up' do
    # should generate a carton
    let!(:shipped_shipment) { shipped_order.shipments.first }
    # should not generate a carton because it's not shipped
    let!(:unshipped_shipment) { create(:shipment) }
    # should not generate a carton because it has no inventory units
    let!(:shipped_shipment_without_units) do
      shipped_order_without_units.shipments.first
    end
    # should not generate a carton because it already has a carton
    let!(:shipped_and_cartonized_shipment) do
      shipped_and_cartonized_order.shipments.first
    end

    let(:shipped_order) { create(:shipped_order, line_items_count: 1, with_cartons: false) }

    let(:shipped_order_without_units) do
      create(:shipped_order, line_items_count: 1) do |order|
        order.inventory_units.delete_all
      end
    end

    let(:shipped_and_cartonized_order) do
      create(:order_ready_to_ship, line_items_count: 1).tap do |order|
        order.shipping.ship_shipment(order.shipments.first)
      end
    end

    it 'creates the expected carton' do
      expect {
        task.invoke
      }.to change { Spree::Carton.count }.by(1)

      carton = Spree::Carton.last

      expect(carton).to be_valid

      expect(carton.imported_from_shipment_id).to eq shipped_shipment.id
      expect(carton.orders).to eq [shipped_order]

      expect(carton.number).to eq "C#{shipped_shipment.number}"
      expect(carton.stock_location).to eq shipped_shipment.stock_location
      expect(carton.address).to eq shipped_shipment.order.ship_address
      expect(carton.shipping_method).to eq shipped_shipment.shipping_method
      expect(carton.tracking).to eq shipped_shipment.tracking
      expect(carton.shipped_at).to eq shipped_shipment.shipped_at
      expect(carton.created_at).to be_present
      expect(carton.updated_at).to be_present

      expect(carton.inventory_units).to match_array shipped_shipment.inventory_units
    end

    describe 'when run a second time' do
      before do
        task.invoke
        task.reenable
      end

      let!(:second_shipped_shipment) { second_shipped_order.shipments.first }

      let(:second_shipped_order) { create(:shipped_order, line_items_count: 1, with_cartons: false) }

      it 'creates only a carton for the second shipment' do
        expect {
          task.invoke
        }.to change { Spree::Carton.count }.by(1)

        carton = Spree::Carton.last

        expect(carton.imported_from_shipment_id).to eq second_shipped_shipment.id
        expect(carton.orders).to eq [second_shipped_order]
      end
    end
  end

  describe 'down' do
    let(:task) do
      Rake::Task['spree:migrations:copy_shipped_shipments_to_cartons:down']
    end

    let!(:migrated_carton) { create(:carton) }
    let!(:preexisting_carton) { create(:carton) }

    let!(:migrated_carton_inventory_units) { migrated_carton.inventory_units.to_a }
    let!(:preexisting_carton_inventory_units) { preexisting_carton.inventory_units.to_a }

    before do
      migrated_carton.update!(imported_from_shipment_id: migrated_carton.inventory_units.first.shipment_id)
    end

    it 'clears out the correct carton' do
      expect {
        task.invoke
      }.to change { Spree::Carton.count }.by(-1)

      expect(Spree::Carton.find_by(id: migrated_carton.id)).to be_nil

      expect(migrated_carton_inventory_units.map(&:reload).map(&:carton_id)).to all(be_nil)
      expect(preexisting_carton_inventory_units.map(&:reload).map(&:carton_id)).to all(eq preexisting_carton.id)
    end
  end
end
