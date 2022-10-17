# frozen_string_literal: true

require 'rails_helper'
require 'generators/solidus/install/install_generator'

RSpec.describe Solidus::InstallGenerator do
  describe '#prepare_options' do
    it 'disables "seeds" and "sample" if "migrate" are disabled' do
      generator = described_class.new([], ['--auto-accept', '--migrate=false'])
      generator.prepare_options

      aggregate_failures do
        expect(generator.instance_variable_get(:@run_migrations)).to eq(false)
        expect(generator.instance_variable_get(:@load_seed_data)).to eq(false)
        expect(generator.instance_variable_get(:@load_sample_data)).to eq(false)
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
  end
end
