require 'spec_helper'

describe 'solidus:upgrade:one_point_three' do
  include_context(
    'rake',
    task_path: Spree::Core::Engine.root.join('lib/tasks/upgrade.rake'),
    task_name: 'solidus:upgrade:one_point_three',
  )

  before do
    load Spree::Core::Engine.root.join('lib/tasks/migrations/migrate_shipping_rate_taxes.rake')
    load Spree::Core::Engine.root.join('lib/tasks/migrations/create_vat_prices.rake')
  end

  it 'runs' do
    expect { task.invoke }.to output(
      /Your Solidus install is ready for Solidus 1.3./
    ).to_stdout
  end
end
