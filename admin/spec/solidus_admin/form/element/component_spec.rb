# frozen_string_literal: true

require "spec_helper"
require "solidus_admin/form/element/component"

RSpec.describe SolidusAdmin::Form::Element::Component do
  describe "#call" do
    it "returns the given instance component" do
      element = described_class.new(component: :component)

      expect(
        element.call(double("form"), double("builder"))
      ).to be(:component)
    end
  end
end
