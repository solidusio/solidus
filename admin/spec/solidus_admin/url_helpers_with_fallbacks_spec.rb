# frozen_string_literal: true

require "spec_helper"
require "solidus_admin/url_helpers_with_fallbacks"

RSpec.describe SolidusAdmin::UrlHelpersWithFallbacks do
  it "delegates to solidus_admin route when it's available there" do
    solidus_admin = Module.new do
      def self.orders_path
        "/admin/orders"
      end
    end
    spree = Module.new do
      def self.admin_orders_path
        "/old_admin/orders"
      end
    end

    expect(
      described_class.new(solidus_admin: solidus_admin, spree: spree).orders_path
    ).to eq "/admin/orders"
  end

  it "fallsback to spree proxy route prefixed with admin when route is not available in solidus_admin" do
    solidus_admin = Module.new
    spree = Module.new do
      def self.admin_orders_path
        "/old_admin/orders"
      end
    end

    expect(
      described_class.new(solidus_admin: solidus_admin, spree: spree).orders_path
    ).to eq "/old_admin/orders"
  end
end
