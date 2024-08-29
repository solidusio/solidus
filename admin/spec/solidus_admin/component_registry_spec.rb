# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::ComponentRegistry do
  let(:registry) { described_class.new }
  let(:key) { "ui/button" }

  subject { registry[key] }

  context "with a default class" do
    it { is_expected.to eq(SolidusAdmin::UI::Button::Component) }
  end

  context "with a spelling mistake" do
    let(:key) { "ui/buton" }

    it "raises an understandable error" do
      expect { subject }.to raise_error("Unknown component ui/buton\nDid you mean?  ui/button")
    end
  end

  context "with a custom class" do
    before do
      # Using an existing class here so I don't have to define a new one.
      # Extensions that use this should use their own.
      registry["ui/button"] = "SolidusAdmin::UI::Panel::Component"
    end

    it { is_expected.to eq(SolidusAdmin::UI::Panel::Component) }
  end

  context "with a custom class with a spelling mistake" do
    before do
      registry["ui/button"] = "DoesNotExistClass"
    end

    it "raises an NameError" do
      expect { subject }.to raise_error("uninitialized constant DoesNotExistClass")
    end
  end
end
