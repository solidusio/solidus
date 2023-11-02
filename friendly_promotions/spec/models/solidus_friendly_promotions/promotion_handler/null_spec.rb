# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusFriendlyPromotions::PromotionHandler::Null do
  let(:order) { double }

  subject { described_class.new(order) }

  it { is_expected.to respond_to(:order) }
  it { is_expected.to respond_to(:error) }
  it { is_expected.to respond_to(:success) }
  it { is_expected.to respond_to(:activate) }
end
