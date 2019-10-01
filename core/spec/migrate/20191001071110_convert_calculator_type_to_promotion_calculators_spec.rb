# frozen_string_literal: true

require 'rails_helper'
require Spree::Core::Engine.root.join('db/migrate/20191001071110_convert_calculator_type_to_promotion_calculators.rb')

RSpec.describe ConvertCalculatorTypeToPromotionCalculators do
  let(:migrations_paths) { ActiveRecord::Migrator.migrations_paths }
  let(:migrations) do
    if Rails.gem_version >= Gem::Version.new('6.0.0')
      ActiveRecord::MigrationContext.new(
        migrations_paths,
        ActiveRecord::SchemaMigration
      ).migrations
    elsif Rails.gem_version >= Gem::Version.new('5.2.0')
      ActiveRecord::MigrationContext.new(migrations_paths).migrations
    else
      ActiveRecord::Migrator.migrations(migrations_paths)
    end
  end
  let(:previous_version) { 20190220093635 }
  let(:current_version) { 20191001071110 }

  subject do
    if Rails.gem_version >= Gem::Version.new('6.0.0')
      ActiveRecord::Migrator.new(:up, migrations, ActiveRecord::SchemaMigration, current_version).migrate
    else
      ActiveRecord::Migrator.new(:up, migrations, current_version).migrate
    end
  end

  # This is needed for MySQL since it is not able to rollback to the previous
  # state when database schema changes within that transaction.
  before(:all) { self.use_transactional_tests = false }
  after(:all)  { self.use_transactional_tests = true }

  around do |example|
    DatabaseCleaner.clean_with(:truncation)
    # Silence migrations output in specs report.
    ActiveRecord::Migration.suppress_messages do
      # Migrate back to the previous version
      if Rails.gem_version >= Gem::Version.new('6.0.0')
        ActiveRecord::Migrator.new(:down, migrations, ActiveRecord::SchemaMigration, previous_version).migrate
      else
        ActiveRecord::Migrator.new(:down, migrations, previous_version).migrate
      end

      example.run

      if Rails.gem_version >= Gem::Version.new('6.0.0')
        ActiveRecord::Migrator.new(:up, migrations, ActiveRecord::SchemaMigration).migrate
      else
        ActiveRecord::Migrator.new(:up, migrations).migrate
      end
    end
    DatabaseCleaner.clean_with(:truncation)
  end

  # This promotion factory creates a promotion action with
  # the flat rate calculator.
  let(:promotion) { create(:promotion, :with_order_adjustment) }
  let(:calculator) { promotion.actions.first.calculator }

  context 'when there are calculators with the old names' do
    before { calculator.update_column(:type, 'Spree::Calculator::FlatRate') }

    it 'converts old names to the new namespace' do
      subject
      expect(promotion.reload.actions.first.calculator.type).to eq 'Spree::Calculator::Promotion::FlatRate'
    end
  end
end
