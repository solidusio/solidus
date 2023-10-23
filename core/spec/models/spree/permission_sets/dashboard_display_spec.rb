# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/dummy_ability'

RSpec.describe Spree::PermissionSets::DashboardDisplay do
  let(:ability) { DummyAbility.new }

  subject { ability }

  context "when activated" do
    before do
      ActiveSupport::Deprecation.warn('The dashboard_display_spec.rb test is being deprecated.  Please update your source code.')
      described_class.new(ability).activate!
    end

    it { is_expected.to be_able_to(:admin, :dashboards) }
    it { is_expected.to be_able_to(:home, :dashboards) }
  end

  context "when not activated" do
    ActiveSupport::Deprecation.warn('The dashboard_display_spec.rb test is being deprecated.  Please update your source code.')
    it { is_expected.not_to be_able_to(:admin, :dashboards) }
    it { is_expected.not_to be_able_to(:home, :dashboards) }
  end
end
