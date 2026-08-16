# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::LogEntry, type: :model do
  describe ".permitted_classes" do
    it "skips configured classes that are no longer defined" do
      stub_spree_preferences(
        log_entry_permitted_classes: ["Date", "Spree::NoLongerDefinedExampleClass"]
      )

      expect { described_class.permitted_classes }.not_to raise_error
      expect(described_class.permitted_classes).to include(Date)
      expect(described_class.permitted_classes).to match_array(
        described_class::CORE_PERMITTED_CLASSES + [Date]
      )
    end
  end

  describe "#parsed_details" do
    it "allows aliases by default" do
      x = []
      x << x

      log_entry = described_class.new(details: x.to_yaml)

      expect { log_entry.parsed_details }.not_to raise_error
    end

    it "can disable aliases and returns a wrapper referencing the meaningful message when used" do
      stub_spree_preferences(log_entry_allow_aliases: false)
      x = []
      x << x

      log_entry = described_class.new(details: x.to_yaml)

      details = log_entry.parsed_details
      expect(details.success?).to eq(false)
      expect(details.params["error"]).to match(/log_entry_allow_aliases/)
    end

    it "can parse ActiveMerchant::Billing::Response instances" do
      response = ActiveMerchant::Billing::Response.new("success", "message")

      log_entry = described_class.new(details: response.to_yaml)

      expect { log_entry.parsed_details }.not_to raise_error
    end

    it "can parse ActiveSupport::TimeWithZone instances" do
      time = Time.zone.now

      log_entry = described_class.new(details: time.to_yaml)

      expect { log_entry.parsed_details }.not_to raise_error
    end

    it "can parse Symbol instances" do
      log_entry = described_class.new(details: :foo.to_yaml)

      expect { log_entry.parsed_details }.not_to raise_error
    end

    it "can parse ActiveSupport::HashWithIndifferentAccess instances" do
      log_entry = described_class.new(details: {"foo" => "bar"}.with_indifferent_access.to_yaml)

      expect { log_entry.parsed_details }.not_to raise_error
    end

    it "can parse user specified class instances" do
      stub_spree_preferences(log_entry_permitted_classes: ["Date"])

      log_entry = described_class.new(details: Date.today)

      expect { log_entry.parsed_details }.not_to raise_error
    end

    it "returns a wrapper referencing the meaningful message when a disallowed class is found" do
      serialized_date = Date.today.to_yaml
      log_entry = described_class.new(details: serialized_date)

      details = log_entry.parsed_details
      expect(details.success?).to eq(false)
      expect(details.message).to include("[WARNING: An error occurred while trying to deserialize the stored payment response]")
      expect(details.params["data"]).to eq(serialized_date)
      expect(details.params["error"]).to match(/log_entry_permitted_classes/)
    end

    it "returns a wrapper when the stored details are malformed YAML" do
      malformed = "{ this: is: not: valid"
      log_entry = described_class.new(details: malformed)

      details = log_entry.parsed_details
      expect(details.success?).to eq(false)
      expect(details.message).to include("[WARNING: An error occurred while trying to deserialize the stored payment response]")
      expect(details.params["data"]).to eq(malformed)
      expect(details.params["error"]).to be_present
    end

    it "reports the deserialization error so it is visible to developers" do
      subscriber = Class.new do
        attr_reader :reported

        def initialize
          @reported = []
        end

        def report(error, handled:, severity:, context:, source: nil)
          @reported << {error: error, handled: handled, severity: severity, context: context}
        end
      end.new
      Rails.error.subscribe(subscriber)

      described_class.new(details: "{ this: is: not: valid").parsed_details

      expect(subscriber.reported.size).to eq(1)
      report = subscriber.reported.first
      expect(report[:error]).to be_a(Psych::Exception)
      expect(report[:handled]).to eq(true)
      expect(report[:severity]).to eq(:warning)
    ensure
      Rails.error.unsubscribe(subscriber) if Rails.error.respond_to?(:unsubscribe)
    end

    it "still parses known classes when the configured permitted list contains a missing class" do
      stub_spree_preferences(
        log_entry_permitted_classes: ["Spree::NoLongerDefinedExampleClass"]
      )
      response = ActiveMerchant::Billing::Response.new("success", "message")
      log_entry = described_class.new(details: response.to_yaml)

      expect { log_entry.parsed_details }.not_to raise_error
    end
  end

  describe "#parsed_details=" do
    it "serializes the provided value to YAML" do
      log_entry = described_class.new(parsed_details: {"foo" => "bar"})

      expect(log_entry.details).to eq("---\nfoo: bar\n")
      expect(log_entry.parsed_details).to eq("foo" => "bar")
    end

    it "allows aliases by default" do
      x = []
      x << x

      log_entry = described_class.new

      expect { log_entry.parsed_details = x }.not_to raise_error
    end

    it "dumps self-referential structures without restricting aliases" do
      stub_spree_preferences(log_entry_allow_aliases: false)
      x = []
      x << x

      log_entry = described_class.new

      expect { log_entry.parsed_details = x }.not_to raise_error
    end

    it "can dump ActiveMerchant::Billing::Response instances" do
      response = ActiveMerchant::Billing::Response.new("success", "message")

      log_entry = described_class.new

      expect { log_entry.parsed_details = response }.not_to raise_error
    end

    it "can dump ActiveSupport::TimeWithZone instances" do
      time = Time.zone.now

      log_entry = described_class.new

      expect { log_entry.parsed_details = time }.not_to raise_error
    end

    it "can dump Symbol instances" do
      log_entry = described_class.new

      expect { log_entry.parsed_details = :foo }.not_to raise_error
    end

    it "can dump ActiveSupport::HashWithIndifferentAccess instances" do
      log_entry = described_class.new

      expect { log_entry.parsed_details = {"foo" => "bar"}.with_indifferent_access }.not_to raise_error
    end

    it "dumps arbitrary class instances without restriction" do
      log_entry = described_class.new

      expect { log_entry.parsed_details = Date.new }.not_to raise_error
    end
  end

  describe "#parsed_payment_response_details_with_fallback=" do
    it "stores the full response and wraps it when it cannot be safely deserialized" do
      log_entry = described_class.new
      bad_response = ActiveMerchant::Billing::Response.new(
        true,
        "FooBar",
        {"data" => {"date" => Date.today}}
      )

      log_entry.parsed_payment_response_details_with_fallback = bad_response
      details = log_entry.parsed_details

      expect(details.success?).to eq(false)
      expect(details.message).to include("[WARNING: An error occurred while trying to deserialize the stored payment response]")
      expect(details.params["data"]).to include("FooBar")
      expect(details.params["error"]).to include("Tried to load unspecified class: Date")
    end
  end
end
