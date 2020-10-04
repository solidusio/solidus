# frozen_string_literal: true

require 'spec_helper'

describe "spree/admin/shared/_navigation_footer", type: :view, partial_double_verification: false do
  let(:user) { FactoryBot.build_stubbed(:admin_user) }
  let(:ability) { Object.new.extend(CanCan::Ability) }
  before do
    allow(view).to receive(:try_spree_current_user).and_return(user)
    allow(controller).to receive(:current_ability).and_return(ability)
  end

  it "has a a login-nav section" do
    render
    expect(rendered).to have_selector("#login-nav")
  end

  context "authorized user" do
    before do
      ability.can :admin, user
    end

    it "has a user-account-link that links to edit_admin_user_path" do
      render
      expect(rendered).to have_link(user.email, href: Spree::Core::Engine.routes.url_helpers.edit_admin_user_path(user))
    end

    it "has not a user-account-link that links to admin_path" do
      render
      expect(rendered).to_not have_link(user.email, href: Spree::Core::Engine.routes.url_helpers.admin_path)
    end
  end

  context "unauthorized user" do
    it "has a user-account-link that links to admin_path" do
      render
      expect(rendered).to_not have_link(user.email, href: Spree::Core::Engine.routes.url_helpers.admin_path)
    end

    it "has not a user-account-link that links to edit_admin_user_path" do
      render
      expect(rendered).to_not have_link(user.email, href: Spree::Core::Engine.routes.url_helpers.edit_admin_user_path(user))
    end
  end

  context "with a required spree_logout_path helper" do
    before do
      allow(view).to receive(:spree_logout_path).and_return("/logout")
    end

    it "has user-logout-link" do
      render
      expect(rendered).to have_link(I18n.t('spree.logout'), href: "/logout")
    end
  end

  context "with a spree.root_path" do
    before do
      allow(view.spree).to receive("root_path").and_return("/")
    end

    it "has a back to store link" do
      render
      expect(rendered).to have_link(I18n.t('spree.back_to_store'), href: "/")
    end
  end
end
