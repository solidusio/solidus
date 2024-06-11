# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::NullPromotionFinder do
  describe ".by_code_or_id" do
    it "raises ActiveRecord::RecordNotFound" do
      expect { described_class.by_code_or_id("promo") }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
