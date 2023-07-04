# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusFriendlyPromotions::RulesTaxon do
  it { is_expected.to belong_to(:taxon) }
  it { is_expected.to belong_to(:rule) }
end
