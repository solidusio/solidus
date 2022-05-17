# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::LogEntry, type: :model do
  describe '#parsed_details' do
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

    it 'can parse user specified classes instances' do
      stub_spree_preferences(log_entry_permitted_classes: ['Date'])

      log_entry = described_class.new(details: Date.today)

      expect { log_entry.parsed_details }.not_to raise_error
    end

    it 'raises a meaningful exception when a disallowed class is found' do
      log_entry = described_class.new(details: Date.today)

      expect { log_entry.parsed_details }.to raise_error(described_class::DisallowedClass, /log_entry_permitted_classes/)
    end
  end
end
