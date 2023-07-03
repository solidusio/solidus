# frozen_string_literal: true

require "spec_helper"
require "solidus_admin/configuration"

RSpec.describe SolidusAdmin::Configuration do
  describe "#main_nav" do
    it "returns the main navigation configuration" do
      expect(described_class.new.main_nav).to be_a(described_class::MainNav)
    end

    it "returns the same instance every time" do
      config = described_class.new

      expect(config.main_nav).to be(config.main_nav)
    end

    it "yields the main navigation configuration" do
      described_class.new.main_nav do |main_nav|
        expect(main_nav).to be_a(described_class::MainNav)
      end
    end
  end
end
