# frozen_string_literal: true

require 'rails_helper'
require 'generators/solidus/install/install_generator'

RSpec.describe Solidus::InstallGenerator do
  describe '#prepare_options' do
    it 'has a default setup' do
      generator = described_class.new([], ['--auto-accept'])
      generator.prepare_options

      aggregate_failures do
        expect(generator.instance_variable_get(:@selected_frontend)).to eq("starter")
        expect(generator.instance_variable_get(:@selected_authentication)).to eq("devise")
        expect(generator.instance_variable_get(:@selected_payment_method)).to eq("paypal")
        expect(generator.instance_variable_get(:@run_migrations)).to eq(true)
        expect(generator.instance_variable_get(:@run_seeds)).to eq(false)
        expect(generator.instance_variable_get(:@run_sample)).to eq(true)
      end
    end

    it 'defaults to "paypal" for payments when frontend is "classic"' do
      generator = described_class.new([], ['--auto-accept', '--frontend=classic'])
      generator.prepare_options

      aggregate_failures do
        expect(generator.instance_variable_get(:@selected_frontend)).to eq("classic")
        expect(generator.instance_variable_get(:@selected_authentication)).to eq("devise")
        expect(generator.instance_variable_get(:@selected_payment_method)).to eq("paypal")
      end
    end

    it 'disables "seeds" and "sample" if "migrate" are disabled' do
      generator = described_class.new([], ['--auto-accept', '--migrate=false'])
      generator.prepare_options

      aggregate_failures do
        expect(generator.instance_variable_get(:@run_migrations)).to eq(false)
        expect(generator.instance_variable_get(:@run_seeds)).to eq(false)
        expect(generator.instance_variable_get(:@run_sample)).to eq(false)
      end
    end

    it 'disables "seeds" when "sample" is enabled' do
      generator = described_class.new([], ['--auto-accept', '--sample=true'])
      generator.prepare_options

      aggregate_failures do
        expect(generator.instance_variable_get(:@run_migrations)).to eq(true)
        expect(generator.instance_variable_get(:@run_seeds)).to eq(false)
        expect(generator.instance_variable_get(:@run_sample)).to eq(true)
      end
    end

    it 'warns when using "enforce_available_locales"' do
      generator = described_class.new([], ['--auto-accept', '--enforce-available-locales'])

      allow(generator).to receive(:warn)
      generator.prepare_options

      expect(generator).to have_received(:warn).once.with(
        a_string_matching('using `solidus:install --enforce-available-locales` is now deprecated')
      )
    end

    it 'warns when using "lib_name"' do
      generator = described_class.new([], ['--auto-accept', '--lib-name'])

      allow(generator).to receive(:warn)
      generator.prepare_options

      expect(generator).to have_received(:warn).once.with(
        a_string_matching('using `solidus:install --lib-name` is now deprecated')
      )
    end

    it 'skips seed and sample data if migrations are disabled' do
      generator = described_class.new([], ['--auto-accept', '--migrate=false'])
      generator.prepare_options

      expect(generator.instance_variable_get(:@run_migrations)).to eq(false)
      expect(generator.instance_variable_get(:@run_seeds)).to eq(false)
      expect(generator.instance_variable_get(:@run_sample)).to eq(false)
    end

    context 'supports legacy frontend option names' do
      it 'transform "solidus_frontend" into "classic"' do
        generator = described_class.new([], ['--auto-accept', '--frontend=solidus_frontend'])
        generator.prepare_options

        expect(generator.instance_variable_get(:@selected_frontend)).to eq('classic')
      end

      it 'transform "solidus_starter_frontend" into "starter"' do
        generator = described_class.new([], ['--auto-accept', '--frontend=solidus_starter_frontend'])
        generator.prepare_options

        expect(generator.instance_variable_get(:@selected_frontend)).to eq('starter')
      end
    end

    context 'when asked interactively' do
      it 'presents different options for the "classic"' do
        questions = []
        generator = described_class.new([], ['--frontend=classic', '--authentication=devise'])
        allow(generator).to receive(:ask_with_description) { |**args| questions << args }

        generator.prepare_options

        expect(questions.size).to eq(1)
        expect(questions.first[:limited_to]).to eq(['paypal', 'bolt', 'none'])
        expect(questions.first[:default]).to eq('paypal')
        expect(strip_ansi questions.first[:desc]).to include('[paypal]')
        expect(strip_ansi questions.first[:desc]).to include('[bolt]')
        expect(strip_ansi questions.first[:desc]).to include('[none]')
      end

      it 'presents different options for the "classic"' do
        questions = []
        generator = described_class.new([], ['--frontend=starter', '--authentication=devise'])
        allow(generator).to receive(:ask_with_description) { |**args| questions << args }

        generator.prepare_options

        expect(questions.size).to eq(1)
        expect(questions.first[:limited_to]).to eq(['paypal', 'none'])
        expect(questions.first[:default]).to eq('paypal')
        expect(strip_ansi questions.first[:desc]).to include('[paypal]')
        expect(strip_ansi questions.first[:desc]).not_to include('[bolt]')
        expect(strip_ansi questions.first[:desc]).to include('[none]')
      end
    end
  end

  describe "#run_data_loaders" do
    it "executes spree_sample:load task only when sample and seed are enabled" do
      generator = described_class.new([], ['--auto-accept', '--sample=true', '--seed=true'])
      allow(generator).to receive(:say_status_and_run_task)

      generator.prepare_options
      generator.run_data_loaders

      aggregate_failures do
        expect(generator).to have_received(:say_status_and_run_task).with("seed and sample data", "spree_sample:load")
        expect(generator).not_to have_received(:say_status_and_run_task).with("seed data", "db:seed")
      end
    end

    it "does not execute spree_sample:load task when sample is disabled" do
      generator = described_class.new([], ['--auto-accept', '--sample=false', '--seed=true'])
      allow(generator).to receive(:say_status_and_run_task)
      allow(generator).to receive(:say_status)

      generator.prepare_options
      generator.run_data_loaders

      aggregate_failures do
        expect(generator).to have_received(:say_status_and_run_task).with("seed data", "db:seed AUTO_ACCEPT=1")
        expect(generator).to have_received(:say_status).with(:skipping, "sample data (you can always run rake spree_sample:load)")
      end
    end

    it "skips both spree_sample:load and db:seed tasks when task and sample are disabled" do
      generator = described_class.new([], ['--auto-accept', '--sample=false', '--seed=false'])
      allow(generator).to receive(:say_status_and_run_task)
      allow(generator).to receive(:say_status)

      generator.prepare_options
      generator.run_data_loaders

      aggregate_failures do
        expect(generator).to have_received(:say_status).with(:skipping, "seed data (you can always run rake db:seed)")
        expect(generator).to have_received(:say_status).with(:skipping, "sample data (you can always run rake spree_sample:load)")
      end
    end

    it "includes expected rake options for db:seed" do
      generator = described_class.new([], ['--auto-accept', '--sample=false', '--seed=true', '--admin_email=test@solidus.io', '--admin_password=P@55word!'])
      allow(generator).to receive(:say_status_and_run_task)
      allow(generator).to receive(:say_status)

      generator.prepare_options
      generator.run_data_loaders

      expect(generator).to have_received(:say_status_and_run_task).with("seed data", "db:seed AUTO_ACCEPT=1 ADMIN_EMAIL=test@solidus.io ADMIN_PASSWORD=P@55word!")
    end
  end

  private

  def strip_ansi(string)
    string.gsub(/\u001b\[.*?m/, '')
  end
end
