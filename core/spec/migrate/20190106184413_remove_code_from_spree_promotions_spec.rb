# frozen_string_literal: true

require 'rails_helper'
require Spree::Core::Engine.root.join('db/migrate/20190106184413_remove_code_from_spree_promotions.rb')

RSpec.describe RemoveCodeFromSpreePromotions do
  let(:migrations_paths) { ActiveRecord::Migrator.migrations_paths }
  let(:migrations) do
    if ActiveRecord::Base.connection.respond_to?(:migration_context)
      # Rails >= 5.2
      ActiveRecord::MigrationContext.new(migrations_paths).migrations
    else
      ActiveRecord::Migrator.migrations(migrations_paths)
    end
  end
  let(:previous_version) { 20180710170104 }
  let(:current_version) { 20190106184413 }

  subject { ActiveRecord::Migrator.new(:up, migrations, current_version).migrate }

  # This is needed for MySQL since it is not able to rollback to the previous
  # state when database schema changes within that transaction.
  before(:all) { self.use_transactional_tests = false }
  after(:all)  { self.use_transactional_tests = true }

  around do |example|
    DatabaseCleaner.clean_with(:truncation)
    # Silence migrations output in specs report.
    ActiveRecord::Migration.suppress_messages do
      # Migrate back to the previous version
      ActiveRecord::Migrator.new(:down, migrations, previous_version).migrate
      # If other tests using Spree::Promotion ran before this one, Rails has
      # stored information about table's columns and we need to reset those
      # since the migration changed the database structure.
      Spree::Promotion.reset_column_information

      example.run

      # Re-update column information after the migration has been executed
      # again in the example. This will make the promotion attributes cache
      # ready for other tests.
      Spree::Promotion.reset_column_information
    end
    DatabaseCleaner.clean_with(:truncation)
  end

  let(:promotion_with_code) { create(:promotion) }

  before do
    # We can't set code via factory since `code=` is currently raising
    # an error, see more at:
    # https://github.com/solidusio/solidus/blob/cf96b03eb9e80002b69736e082fd485c870ab5d9/core/app/models/spree/promotion.rb#L65
    promotion_with_code.update_column(:code, code)
  end

  context 'when there are no promotions with code' do
    let(:code) { '' }

    it 'does not call any promotion with code handler' do
      expect(described_class).not_to receive(:promotions_with_code_handler)

      subject
    end
  end

  context 'when there are promotions with code' do
    let(:code) { 'Just An Old Promo Code' }

    context 'with the deafult handler (Solidus::Migrations::PromotionWithCodeHandlers::RaiseException)' do
      it 'raise a StandardError exception' do
        expect { subject }.to raise_error(StandardError)
      end
    end

    context 'changing the default handler' do
      before do
        allow(described_class)
          .to receive(:promotions_with_code_handler)
          .and_return(promotions_with_code_handler)
      end

      context 'to Solidus::Migrations::PromotionWithCodeHandlers::MoveToSpreePromotionCode' do
        let(:promotions_with_code_handler) { Solidus::Migrations::PromotionWithCodeHandlers::MoveToSpreePromotionCode }

        context 'when there are no Spree::PromotionCode with the same value' do
          it 'moves the code into a Spree::PromotionCode' do
            migration_context = double('a migration context')
            allow_any_instance_of(promotions_with_code_handler)
              .to receive(:migration_context)
              .and_return(migration_context)

            expect(migration_context)
              .to receive(:say)
              .with("Creating Spree::PromotionCode with value 'just an old promo code' for Spree::Promotion with id '#{promotion_with_code.id}'")

            expect { subject }
              .to change { Spree::PromotionCode.all.size }
              .from(0)
              .to(1)
          end
        end

        context 'with promotions with type set (legacy feature)' do
          let(:promotion_with_code) { create(:promotion, type: 'Spree::Promotion') }

          it 'does not raise a STI error' do
            expect { subject }.not_to raise_error
          end
        end

        context 'when there is a Spree::PromotionCode with the same value' do
          context 'associated with the same promotion' do
            let!(:existing_promotion_code) { create(:promotion_code, value: 'just an old promo code', promotion: promotion_with_code) }

            it 'does not create a new Spree::PromotionCode' do
              expect { subject }.not_to change { Spree::PromotionCode.all.size }
            end
          end

          context 'associated with another promotion' do
            let!(:existing_promotion_code) { create(:promotion_code, value: 'just an old promo code') }

            it 'raises an exception' do
              expect { subject }.to raise_error(StandardError)
            end
          end
        end
      end

      context 'to Solidus::Migrations::PromotionWithCodeHandlers::DoNothing' do
        let(:promotions_with_code_handler) { Solidus::Migrations::PromotionWithCodeHandlers::DoNothing }

        it 'just prints a message' do
          migration_context = double('a migration context')
          allow_any_instance_of(promotions_with_code_handler)
            .to receive(:migration_context)
            .and_return(migration_context)

          expect(migration_context)
            .to receive(:say)
            .with("Code 'Just An Old Promo Code' is going to be removed from Spree::Promotion with id '#{promotion_with_code.id}'")

          subject
        end
      end
    end
  end
end
