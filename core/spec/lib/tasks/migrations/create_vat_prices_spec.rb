require 'spec_helper'

describe 'solidus:migrations:create_vat_prices' do
  describe 'up' do
    include_context(
      'rake',
      task_path: Spree::Core::Engine.root.join('lib/tasks/migrations/create_vat_prices.rake'),
      task_name: 'solidus:migrations:create_vat_prices:up',
    )

    context "without a zone" do
      it 'skips' do
        expect { task.invoke }.to output(
          "Creating differentiated prices for VAT countries ... No Zone set as default_tax. Skipping.\n"
        ).to_stdout
      end
    end

    context "with a zone" do
      let!(:zone) { create(:zone, :with_country, default_tax: true) }

      it 'runs' do
        expect { task.invoke }.to output(
          "Creating differentiated prices for VAT countries ... Success.\n"
        ).to_stdout
      end
    end
  end
end
