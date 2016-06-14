require 'spec_helper'

describe 'solidus:migrations:create_vat_prices' do
  describe 'up' do
    include_context(
      'rake',
      task_path: Spree::Core::Engine.root.join('lib/tasks/migrations/create_vat_prices.rake'),
      task_name: 'solidus:migrations:create_vat_prices:up',
    )

    # TODO: Update to work if this is missing, and add more specs
    let!(:zone) { create(:zone, :with_country, default_tax: true) }

    it 'runs' do
      expect { task.invoke }.to output(
        "Creating differentiated prices for VAT countries ... Success.\n"
      ).to_stdout
    end
  end
end
