# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::AppConfiguration do
  let(:prefs) { Spree::Config }

  describe "#adjustment_promotion_source_types" do
    subject { prefs.adjustment_promotion_source_types }

    it { is_expected.to contain_exactly(Spree::PromotionAction) }
  end
end
