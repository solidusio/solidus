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
        expect(generator.instance_variable_get(:@load_seed_data)).to eq(true)
        expect(generator.instance_variable_get(:@load_sample_data)).to eq(true)
      end
    end

    it 'defaults to "paypal" for payments when frontend is "starter"' do
      generator = described_class.new([], ['--auto-accept', '--frontend=starter'])
      generator.prepare_options

      aggregate_failures do
        expect(generator.instance_variable_get(:@selected_frontend)).to eq("starter")
        expect(generator.instance_variable_get(:@selected_authentication)).to eq("devise")
        expect(generator.instance_variable_get(:@selected_payment_method)).to eq("paypal")
      end
    end

    it 'disables "seeds" and "sample" if "migrate" are disabled' do
      generator = described_class.new([], ['--auto-accept', '--migrate=false'])
      generator.prepare_options

      aggregate_failures do
        expect(generator.instance_variable_get(:@run_migrations)).to eq(false)
        expect(generator.instance_variable_get(:@load_seed_data)).to eq(false)
        expect(generator.instance_variable_get(:@load_sample_data)).to eq(false)
      end
    end

    it 'skips seed and sample data if migrations are disabled' do
      generator = described_class.new([], ['--auto-accept', '--migrate=false'])
      generator.prepare_options

      expect(generator.instance_variable_get(:@run_migrations)).to eq(false)
      expect(generator.instance_variable_get(:@load_seed_data)).to eq(false)
      expect(generator.instance_variable_get(:@load_sample_data)).to eq(false)
    end

    it 'skips sample data if seeds are disabled' do
      generator = described_class.new([], ['--auto-accept', '--seed=false'])
      generator.prepare_options

      expect(generator.instance_variable_get(:@run_migrations)).to eq(true)
      expect(generator.instance_variable_get(:@load_seed_data)).to eq(false)
      expect(generator.instance_variable_get(:@load_sample_data)).to eq(false)
    end

    context 'when asked interactively' do
      it 'presents different options for the "starter"' do
        questions = []
        generator = described_class.new([], ['--frontend=starter', '--authentication=devise'])
        allow(generator).to receive(:ask_with_description) { |**args| questions << args }

        generator.prepare_options

        expect(questions.size).to eq(1)
        expect(questions.first[:limited_to]).to eq(['paypal', 'stripe', 'braintree', 'none'])
        expect(questions.first[:default]).to eq('paypal')
        expect(strip_ansi questions.first[:desc]).to include('[paypal]')
        expect(strip_ansi questions.first[:desc]).to include('[stripe]')
        expect(strip_ansi questions.first[:desc]).not_to include('[bolt]')
        expect(strip_ansi questions.first[:desc]).to include('[braintree]')
        expect(strip_ansi questions.first[:desc]).to include('[none]')
      end
    end
  end

  private

  def strip_ansi(string)
    string.gsub(/\u001b\[.*?m/, '')
  end
end
