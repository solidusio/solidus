# frozen_string_literal: true

require "spec_helper"
require "solidus_admin/form/element/html"

RSpec.describe SolidusAdmin::Form::Element::HTML do
  describe "#call" do
    it "returns itself" do
      element = described_class.new(html: "foo")

      expect(
        element.call(double("form"), double("builder"))
      ).to be(element)
    end
  end

  describe "#render_in" do
    it "returns the given HTML" do
      element = described_class.new(html: "foo")

      expect(
        element.render_in(double("view_context"))
      ).to eq("foo")
    end
  end
end
