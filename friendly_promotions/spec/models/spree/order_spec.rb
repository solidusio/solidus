# frozen_string_literal: true

require "spec_helper"

RSpec.describe Spree::Order do
  it { is_expected.to have_many :friendly_promotions }
  it { is_expected.to have_many :friendly_order_promotions }
end
