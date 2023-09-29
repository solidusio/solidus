# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusAdmin::LayoutHelper, :helper do
  describe '#current_locale' do
    it "returns the current locale" do
      expect(
        helper.current_locale(backend: double(locale: :en))
      ).to eq(:en)
    end
  end

  describe '#solidus_admin_title' do
    it "includes the store name" do
      expect(
        helper.solidus_admin_title(store_name: "My Store")
      ).to include("My Store")
    end

    it "includes the translated controller base name" do
      expect(helper.solidus_admin_title(store_name: "My Store", controller_name: 'products')).to eq("My Store - Products")
    end
  end
end
