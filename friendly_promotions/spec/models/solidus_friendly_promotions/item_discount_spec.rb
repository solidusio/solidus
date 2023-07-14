# frozen_string_literal: true

require 'spec_helper'


RSpec.describe SolidusFriendlyPromotions::ItemDiscount do
  it { is_expected.to respond_to(:item_id) }
  it { is_expected.to respond_to(:source) }
  it { is_expected.to respond_to(:amount) }
  it { is_expected.to respond_to(:label) }
end
