# frozen_string_literal: true

require 'rails_helper'

path = Spree::Core::Engine.root.join('lib/tasks/migrations/migrate_address_names.rake')

RSpec.describe 'solidus:migrations:migrate_address_names' do
  around do |example|
    ignored_columns = Spree::Address.ignored_columns
    Spree::Address.ignored_columns = []
    Spree::Address.reset_column_information

    original_stderr = $stderr
    original_stdout = $stdout
    $stderr = File.open(File::NULL, "w")
    $stdout = File.open(File::NULL, "w")

    example.run
  ensure
    $stderr = original_stderr
    $stdout = original_stdout

    Spree::Address.ignored_columns = ignored_columns
    Spree::Address.reset_column_information
  end

  describe 'up' do
    include_context(
      'rake',
      task_path: path,
      task_name: 'solidus:migrations:migrate_address_names:up'
    )

    context "when there are no records to migrate" do
      it "simply exits" do
        expect { task.invoke }.to output(
          "Combining addresses' firstname and lastname into name ... \n  Your DB contains 0 addresses that may be affected by this task.\n"
        ).to_stdout
      end
    end

    context "when there are records to migrate" do
      let!(:complete_address) { create(:address, firstname: 'Jane', lastname: 'Smith') }
      let!(:partial_address) { create(:address, firstname: nil, lastname: 'Doe') }

      before do
        Spree::Address.update_all(name: nil)
      end

      context "when the DB adapter is not supported" do
        before do
          allow(ActiveRecord::Base.connection).to receive(:adapter_name) { 'ms_sql' }
        end

        it "exists with error" do
          expect { task.invoke }.to raise_error(SystemExit)
        end
      end

      context "when the DB adapter is supported" do
        before do
          allow_any_instance_of(Thor::Shell::Basic).to receive(:ask).with(
            '  Do you want to proceed?',
            limited_to: ['Y', 'N'],
            case_insensitive: true
          ).and_return('Y')

          allow_any_instance_of(Thor::Shell::Basic).to receive(:ask).with(
            '  Please enter a different batch size, or press return to confirm the default: '
          ).and_return(size)
        end

        context 'when providing valid batch size number' do
          let(:size) { 10 }

          it 'migrates name data by setting the actual field on the DB' do
            expect { task.invoke }.to change { complete_address.reload[:name] }.to('Jane Smith')
              .and change { partial_address.reload[:name] }.to('Doe')
          end
        end

        context 'when providing invalid batch size number' do
          let(:size) { 'foobar' }

          it 'exits without migrating name data' do
            expect { task.invoke }.to raise_error(SystemExit)
            expect(Spree::Address.pluck(:name)).to be_all(&:nil?)
          end
        end
      end
    end
  end
end
