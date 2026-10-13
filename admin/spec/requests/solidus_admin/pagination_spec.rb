# frozen_string_literal: true

require "spec_helper"

RSpec.describe "SolidusAdmin pagination", type: :request do
  let(:admin_user) { create(:admin_user) }

  before do
    allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(admin_user)
  end

  def current_page
    controller.instance_variable_get(:@page)
  end

  describe "ordering with duplicate sort values" do
    before { create_list(:product, 25, name: "Same Name") }

    it "returns every record exactly once across pages" do
      get solidus_admin.products_path(page: 1)
      first = current_page.records.map(&:id)
      get solidus_admin.products_path(page: 2)
      second = current_page.records.map(&:id)

      expect(first & second).to be_empty
      expect((first + second).uniq.size).to eq(25)
    end

    it "orders by ordered_by, then by primary key" do
      get solidus_admin.products_path

      expect(current_page.to_sql).to match(/ORDER BY .*.name. ASC, .*.id. ASC/i)
    end
  end
end
