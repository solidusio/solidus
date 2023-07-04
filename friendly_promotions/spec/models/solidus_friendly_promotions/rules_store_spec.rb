# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusFriendlyPromotions::RulesStore do
  it { is_expected.to belong_to(:store) }
  it { is_expected.to belong_to(:rule) }
end
