require 'spec_helper'

describe 'solidus:migrations:assure_store_on_orders' do
  describe 'up' do
    include_context(
      'rake',
      task_path: Spree::Core::Engine.root.join('lib/tasks/migrations/assure_store_on_orders.rake'),
      task_name: 'solidus:migrations:assure_store_on_orders:up',
    )

    context 'with no orders' do
      it 'succeeds' do
        expect { task.invoke }.to output(
          "Everything is good, all orders in your database have a store attached.\n"
        ).to_stdout
      end
    end

    context 'when all orders have store_ids' do
      let!(:order) { create(:order, store: create(:store)) }

      it 'succeeds' do
        expect { task.invoke }.to output(
          "Everything is good, all orders in your database have a store attached.\n"
        ).to_stdout
      end
    end

    context 'when some orders do not have store_ids' do
      let!(:order_with_store) { create(:order, store: store) }
      let!(:order_without_store) do
        # due to a before_validation that adds a store when one is missing,
        # we can't simply specify `store: nil`
        create(:order, store: store).tap do |o|
          o.update_columns(store_id: nil)
        end
      end
      let!(:store) { create(:store) }

      it 'succeeds' do
        expect { task.invoke }.to output(
          "All orders updated with the default store.\n"
        ).to_stdout
      end
    end
  end
end
