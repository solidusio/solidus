# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::Api::Config do
  describe "#adjustment_attributes" do
    subject { described_class.adjustment_attributes }

    it { is_expected.to include(:promotion_code_id) }
    it { is_expected.to include(:eligible) }
  end
end
