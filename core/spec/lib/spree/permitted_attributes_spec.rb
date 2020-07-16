# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::PermittedAttributes do
  describe ".checkout_attributes" do
    subject(:permitted_attributes) { described_class }

    it "when read emits a deprecation warning and return all steps attributes" do
      expect(Spree::Deprecation).to receive(:warn)
      all_attributes = permitted_attributes.checkout_attributes

      expect(all_attributes).to include(*permitted_attributes.checkout_address_attributes)
      expect(all_attributes).to include(*permitted_attributes.checkout_delivery_attributes)
      expect(all_attributes).to include(*permitted_attributes.checkout_payment_attributes)
    end

    it "when changed emits a deprecation warning and push changes to all steps' attributes" do
      expect(Spree::Deprecation).to receive(:warn).exactly(4).times
      permitted_attributes.checkout_attributes.push :appended_attribute
      permitted_attributes.checkout_attributes.append :appended_with_alias_attribute
      permitted_attributes.checkout_attributes << :another_appended_attribute
      permitted_attributes.checkout_attributes.prepend :prepended_attribute

      checkout_steps_attributes = [
        permitted_attributes.checkout_address_attributes,
        permitted_attributes.checkout_delivery_attributes,
        permitted_attributes.checkout_payment_attributes,
        permitted_attributes.checkout_confirm_attributes
      ]

      checkout_steps_attributes.each do |step_attributes|
        expect(step_attributes).to include(
          :appended_attribute,
          :appended_with_alias_attribute,
          :another_appended_attribute,
          :prepended_attribute)
      end
    end
  end
end
