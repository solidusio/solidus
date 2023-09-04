# frozen_string_literal: true

require "spec_helper"
require "solidus_admin/configuration"

RSpec.describe SolidusAdmin::Configuration do
  describe "#menu_items" do
    it "returns an array of hashes" do
      expect(described_class.new.menu_items).to be_an(Array)
      expect(described_class.new.menu_items).not_to be_empty
      expect(described_class.new.menu_items.first).to be_a(Hash)
    end

    it "returns the same instance every time" do
      config = described_class.new

      expect(config.menu_items).to be(config.menu_items)
    end
  end

  describe "#components" do
    it "returns a component class given a key" do
      config = described_class.new
      expect(config.components["ui/button"]).to eq(SolidusAdmin::UI::Button::Component)
    end

    it "suggests the correct name if a typo is found" do
      config = described_class.new
      expect{ config.components["ui/buton"] }.to raise_error("Unknown component ui/buton\nDid you mean?  ui/button")
    end
  end
end
