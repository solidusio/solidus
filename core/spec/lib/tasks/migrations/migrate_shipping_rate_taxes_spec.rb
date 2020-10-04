# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'solidus:migrations:migrate_shipping_rate_taxes' do
  describe 'up' do
    before do
      expect(Spree::Deprecation).to receive(:warn).
        with(/^rake spree:migrations:migrate_shipping_rate_taxes:up has been deprecated/, any_args)
    end

    include_context(
      'rake',
      task_path: Spree::Core::Engine.root.join('lib/tasks/migrations/migrate_shipping_rate_taxes.rake'),
      task_name: 'solidus:migrations:migrate_shipping_rate_taxes:up',
    )

    it 'runs' do
      expect { task.invoke }.to output(
        "Adding persisted tax notes to historic shipping rates ... Success.\n"
      ).to_stdout
    end
  end
end
