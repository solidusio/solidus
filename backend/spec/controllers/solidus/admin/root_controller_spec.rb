# frozen_string_literal: true

require 'spec_helper'

describe Solidus::Admin::RootController do
  describe "GET index" do
    subject { get :index }

    let(:user) { build(:user) }
    let(:ability) { Solidus::Ability.new(user) }

    before do
      allow_any_instance_of(Solidus::Admin::RootController).to receive(:try_spree_current_user).and_return(user)
      allow_any_instance_of(Solidus::Admin::RootController).to receive(:current_ability).and_return(ability)
    end

    context "when a user can admin and display spree orders" do
      before do
        ability.can :admin, Solidus::Order
        ability.can :display, Solidus::Order
      end

      it { is_expected.to redirect_to(spree.admin_orders_path) }
    end

    context "when a user cannot admin and display spree orders" do
      context "when a user can admin and home dashboards" do
        before do
          ability.can :admin, :dashboards
          ability.can :home, :dashboards
        end

        it { is_expected.to redirect_to(spree.home_admin_dashboards_path) }
      end

      context "when a user cannot admin and home dashboards" do
        # The default exception handler redirects to /unauthorized.
        # Extensions may change this.
        it { is_expected.to redirect_to('/unauthorized') }
      end
    end
  end
end
