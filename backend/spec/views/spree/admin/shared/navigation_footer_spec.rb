require 'spec_helper'

describe "spree/admin/shared/_navigation_footer", type: :view do
  let(:user) { create(:admin_user) }
  before do
    allow(view).to receive(:try_spree_current_user).and_return(user)
  end

  it "has a a login-nav section" do
    render
    expect(rendered).to have_selector("#login-nav")
  end

  it "has a user-account-link" do
    render
    expect(rendered).to have_link(user.email, href: Spree::Core::Engine.routes.url_helpers.edit_admin_user_path(user))
  end

  context "with a required spree_logout_path helper" do
    before do
      allow(view).to receive(:spree_logout_path).and_return("/logout")
    end

    it "has user-logout-link" do
      render
      expect(rendered).to have_link(Spree.t(:logout), href: "/logout")
    end
  end

  context "with a spree.root_path" do
    before do
      allow(view.spree).to receive("root_path").and_return("/")
    end

    it "has a back to store link" do
      render
      expect(rendered).to have_link(Spree.t(:back_to_store), href: "/")
    end
  end

end
