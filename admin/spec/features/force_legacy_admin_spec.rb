# frozen_string_literal: true

require "spec_helper"

describe "Forcing the legacy admin", :with_generated_routes, type: :feature do
  let(:admin_user) { create(:admin_user) }

  before do
    sign_in(admin_user)
    stub_authorization!(admin_user)
  end

  def with_force_legacy_admin_proc(proc)
    original = SolidusAdmin::Config.force_legacy_admin_proc
    SolidusAdmin::Config.force_legacy_admin_proc = proc
    yield
  ensure
    SolidusAdmin::Config.force_legacy_admin_proc = original
  end

  def legacy_admin?
    page.has_css?("body.admin")
  end

  it "serves the new admin by default" do
    visit "/admin/products"

    expect(legacy_admin?).to be(false)
  end

  it "serves the legacy admin for requests the proc matches" do
    with_force_legacy_admin_proc(->(req) { req.path.start_with?("/admin/products") }) do
      visit "/admin/products"

      expect(legacy_admin?).to be(true)
    end
  end

  it "keeps serving the new admin for requests the proc does not match" do
    with_force_legacy_admin_proc(->(req) { req.path.start_with?("/admin/products") }) do
      visit "/admin/stores"

      expect(legacy_admin?).to be(false)
    end
  end
end
