# frozen_string_literal: true

require 'spec_helper'
require 'spree/event/configuration'

RSpec.describe Spree::Event::Configuration do
  describe '#adapter' do
    context "when it hasn't been explicitly set" do
      let(:supress_warning_env_key) { Spree::Event::Adapters::DeprecationHandler::CI_LEGACY_ADAPTER_ENV_KEY }

      it 'is ActiveSupportNotifications adapter' do
        allow(Spree::Deprecation).to receive(:warn)

        expect(described_class.new.adapter).to be(Spree::Event::Adapters::ActiveSupportNotifications)
      end

      it 'renders a deprecation message when no supressed via env' do
        old_value = ENV[supress_warning_env_key]
        ENV[supress_warning_env_key] = nil
        expect(Spree::Deprecation).to receive(:warn).with(/adapter is.*deprecated/m)

        described_class.new.adapter
      ensure
        ENV[supress_warning_env_key] = old_value
      end

      it "doesn't render a deprecation message when supressed via env" do
        old_value = ENV[supress_warning_env_key]
        ENV[supress_warning_env_key] = '1'
        expect(Spree::Deprecation).not_to receive(:warn).with(/adapter is.*deprecated/m)

        described_class.new.adapter
      ensure
        ENV[supress_warning_env_key] = old_value
      end
    end

    context "when it has been explicitly set" do
      it "doesn't render a deprecation message" do
        expect(Spree::Deprecation).not_to receive(:warn)

        config = described_class.new
        config.adapter = Spree::Event::Adapters::ActiveSupportNotifications

        config.adapter
      end
    end
  end
end
