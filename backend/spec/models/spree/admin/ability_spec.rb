require "spec_helper"

describe Spree::Admin::Ability do
  let(:ability) { described_class.new(user) }
  let(:user) { build_stubbed :user }

  describe "#can?" do
    subject { ability }

    before do
      allow(user).to receive(:has_spree_role?).and_return(false)

      allow(user).to receive(:has_spree_role?).
        with(role).
        and_return(has_role)
    end

    context "displaying dashboards" do
      let(:role) { :dashboard_display }

      context "when the user has the dashboard_display role" do
        let(:has_role) { true }

        it { should be_able_to(:admin, :dashboards) }
        it { should be_able_to(:home, :dashboards) }
      end

      context "when the user does not have the dashboard_display role" do
        let(:has_role) { false }

        it { should_not be_able_to(:admin, :dashboards) }
        it { should_not be_able_to(:home, :dashboards) }
      end
    end
  end
end
