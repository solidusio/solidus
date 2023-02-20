# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::LogEntry, type: :model do
  describe '#parsed_details' do
    it 'allows aliases by default' do
      x = []
      x << x

      log_entry = described_class.new(details: x.to_yaml)

      expect { log_entry.parsed_details }.not_to raise_error
    end

    it 'can disable aliases and raises a meaningful exception when used' do
      stub_spree_preferences(log_entry_allow_aliases: false)
      x = []
      x << x

      log_entry = described_class.new(details: x.to_yaml)

      expect { log_entry.parsed_details }.to raise_error(described_class::BadAlias, /log_entry_allow_aliases/)
    end

    it 'can parse ActiveMerchant::Billing::Response instances' do
      response = ActiveMerchant::Billing::Response.new('success', 'message')

      log_entry = described_class.new(details: response.to_yaml)

      expect { log_entry.parsed_details }.not_to raise_error
    end

    it 'can parse ActiveSupport::TimeWithZone instances' do
      time = Time.zone.now

      log_entry = described_class.new(details: time.to_yaml)

      expect { log_entry.parsed_details }.not_to raise_error
    end

    it 'can parse user specified class instances' do
      stub_spree_preferences(log_entry_permitted_classes: ['Date'])

      log_entry = described_class.new(details: Date.today)

      expect { log_entry.parsed_details }.not_to raise_error
    end

    it 'raises a meaningful exception when a disallowed class is found' do
      log_entry = described_class.new(details: Date.today)

      expect { log_entry.parsed_details }.to raise_error(described_class::DisallowedClass, /log_entry_permitted_classes/)
    end
  end

  describe '#parsed_details=' do
    it 'serializes the provided value to YAML' do
      log_entry = described_class.new(parsed_details: { "foo" => "bar" })

      expect(log_entry.details).to eq("---\nfoo: bar\n")
      expect(log_entry.parsed_details).to eq("foo" => "bar")
    end

    it 'allows aliases by default' do
      x = []
      x << x

      log_entry = described_class.new

      expect { log_entry.parsed_details = x }.not_to raise_error
    end

    it 'can disable aliases and raises a meaningful exception when used' do
      stub_spree_preferences(log_entry_allow_aliases: false)
      x = []
      x << x

      log_entry = described_class.new

      expect { log_entry.parsed_details = x }.to raise_error(described_class::BadAlias, /log_entry_allow_aliases/)
    end

    it 'can dump ActiveMerchant::Billing::Response instances' do
      response = ActiveMerchant::Billing::Response.new('success', 'message')

      log_entry = described_class.new

      expect { log_entry.parsed_details = response }.not_to raise_error
    end

    it 'can dump ActiveSupport::TimeWithZone instances' do
      time = Time.zone.now

      log_entry = described_class.new

      expect { log_entry.parsed_details = time }.not_to raise_error
    end

    it 'can dump user specified class instances' do
      stub_spree_preferences(log_entry_permitted_classes: ['Date'])

      log_entry = described_class.new

      expect { log_entry.parsed_details = Date.new }.not_to raise_error
    end

    it 'raises a meaningful exception when a disallowed class is found' do
      log_entry = described_class.new

      expect { log_entry.parsed_details = Date.new }.to raise_error(
        described_class::DisallowedClass, /log_entry_permitted_classes/
      )
    end
  end
end
