# frozen_string_literal: true

require "rails_helper"
require "spree/testing_support/factory_bot"

RSpec.describe Spree::TestingSupport::FactoryBot do
  describe ".check_version" do
    it "raises when FactoryBot version is not supported" do
      stub_const("FactoryBot::VERSION", "4.7.0")

      expect { described_class.check_version }.to raise_error(/Please be aware that the supported version of FactoryBot is >= 4.8/)
    end

    it "does not raise when FactoryBot version is supported" do
      stub_const("FactoryBot::VERSION", "4.8.0")

      expect { described_class.check_version }.not_to raise_error
    end
  end
end
