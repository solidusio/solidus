# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::SolidusFormHelper, :helper do
  describe "#solidus_form_for" do
    it "renders form" do
      result = helper.solidus_form_for(Spree::Product.new, url: "/products") {}
      expect(result).to include("<form")
    end
  end
end
