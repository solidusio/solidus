# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::Address::Name do
  it "concatenates components to form a full name" do
    name = described_class.new("Jane", "Von", "Doe")

    expect(name.to_s).to eq("Jane Von Doe")
  end

  it "keeps first name and last name" do
    name = described_class.new("Jane", "Doe")

    expect(name.first_name).to eq("Jane")
    expect(name.last_name).to eq("Doe")
  end

  it "splits full name to emulate first name and last name" do
    name = described_class.new("Jane Von Doe")

    expect(name.first_name).to eq("Jane")
    expect(name.last_name).to eq("Von Doe")
  end
end
