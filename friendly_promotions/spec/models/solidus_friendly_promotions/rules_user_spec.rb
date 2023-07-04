# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusFriendlyPromotions::RulesUser do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:rule) }
end
