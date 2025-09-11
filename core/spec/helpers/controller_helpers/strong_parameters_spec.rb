# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::Core::ControllerHelpers::StrongParameters, type: :controller do
  controller(ApplicationController) {
    include Spree::Core::ControllerHelpers::StrongParameters
  }

  describe "#permitted_attributes" do
    it "returns Spree::PermittedAttributes module" do
      expect(controller.permitted_attributes).to eq Spree::PermittedAttributes
    end
  end

  describe "#permitted_payment_attributes" do
    it "returns Array class" do
      expect(controller.permitted_payment_attributes.class).to eq Array
    end
  end

  describe "#permitted_order_attributes" do
    it "returns Array class" do
      expect(controller.permitted_order_attributes.class).to eq Array
    end
  end

  describe "#permitted_product_attributes" do
    it "returns Array class" do
      expect(controller.permitted_product_attributes.class).to eq Array
    end
  end
end
