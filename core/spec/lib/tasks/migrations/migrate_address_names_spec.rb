# frozen_string_literal: true

require 'rails_helper'

path = Spree::Core::Engine.root.join('lib/tasks/migrations/migrate_address_names.rake')

RSpec.describe 'solidus:migrations:migrate_address_names' do
  before do
    self.use_transactional_tests = false
  end

  after do
    cleanup_address_data
    self.use_transactional_tests = true
  end

  describe 'up' do
    include_context(
      'rake',
      task_path: path,
      task_name: 'solidus:migrations:migrate_address_names:up'
    )

    it 'migrates name data' do
      address = create(:address, firstname: 'Jane', lastname: 'Von Doe')

      expect { task.invoke }.to output(
        "Updating 1 addresses\nAddresses updated\n"
      ).to_stdout
      expect(address.reload.name).to eq('Jane Von Doe')
    end
  end

  describe 'down' do
    include_context(
      'rake',
      task_path: path,
      task_name: 'solidus:migrations:migrate_address_names:down'
    )

    it 'rollbacks name data migration' do
      address = create(:address, name: 'Jane')

      expect { task.invoke }.to output(
        "Updating 1 addresses\nAddresses updated\n"
      ).to_stdout
      expect(address.reload.name).to be_nil
    end
  end

  private

  def cleanup_address_data
    Spree::Address.delete_all
    Spree::State.delete_all
    Spree::Country.delete_all
    Spree::Address.reset_column_information
  end
end
