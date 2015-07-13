require 'spec_helper'

describe Spree::Admin::RootController do
  describe "GET index" do
    before do
      Spree::Admin::RootController.any_instance.stub(:spree_current_user).and_return(nil)
    end

    subject { get :index }

    context "when a user can admin and display spree orders" do
      before do
        allow_any_instance_of(Spree::Ability).to receive(:can?).
          with(:admin, Spree::Order).
          and_return(true)

        allow_any_instance_of(Spree::Ability).to receive(:can?).
          with(:display, Spree::Order).
          and_return(true)
      end

      it { should redirect_to(spree.admin_orders_path) }
    end

    context "when a user cannot admin and display spree orders" do
      it { should redirect_to(spree.home_admin_dashboards_path) }
    end
  end
end
