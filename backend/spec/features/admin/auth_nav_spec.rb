require 'spec_helper'

describe "Auth Nav Element", type: :feature do
  stub_authorization!

  let(:user) { create(:admin_user) }
  before do
    allow_any_instance_of(ApplicationController).to receive(:spree_current_user).and_return(user)
    allow_any_instance_of(ApplicationHelper).to receive(:spree_current_user).and_return(user)
  end

  it "has a a login-nav section" do
    visit spree.admin_path
    page.find "#login-nav"
  end

  it "has a user-account-link" do
    visit spree.admin_path
    within("#login-nav") do
      page.find_link user.email, href: Spree::Core::Engine.routes.url_helpers.edit_admin_user_path(user)
    end
  end

  context "with a required spree_logout_path helper" do
    before do
      allow_any_instance_of(ApplicationController).to receive(:spree_logout_path).and_return("/logout")
      allow_any_instance_of(ApplicationHelper).to receive(:spree_logout_path).and_return("/logout")
    end

    it "has user-logout-link" do
      visit spree.admin_path
      within("#login-nav") do
        link = page.find_link Spree.t(:logout)
        expect(link["href"]).to eq "/logout"
      end
    end
  end

  context "with a spree.root_path" do
    before(:example) do
      # We need to temporarily add a spree.root_path into the existing routes.
      # Rails offers pretty much no API to do that, this was the best I could do.

      reloader = Rails.application.routes_reloader
      @load_extra_routes = true
      allow(reloader).to receive(:load_paths).and_wrap_original do |m, *args|
        m.call(*args).tap {
          load 'spec/test_routes/add_spree_root_routes.rb' if @load_extra_routes
        }
      end
      reloader.reload!
    end

    after do
      @load_extra_routes = false
      Rails.application.routes_reloader.reload!
    end

    it "has a back to store link" do
      visit spree.admin_path
      within("#login-nav") do
        page.find_link Spree.t(:back_to_store), href: "/"
      end
    end
  end
end
