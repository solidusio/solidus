# frozen_string_literal: true

require "spec_helper"

describe SolidusAdmin::ControllerHelpers::Pagination, type: :controller do
  controller(SolidusAdmin::BaseController) do
    def index
      set_page_and_extract_portion_from(Spree::Product.all, per_page: 5)
      render plain: @page.limit_value
    end
  end

  before do
    allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(create(:admin_user))
  end

  describe "#set_page_and_extract_portion_from" do
    it "is deprecated but still paginates into @page" do
      expect(Spree.deprecator).to receive(:warn).with(/set_page_and_extract_portion_from is deprecated/)

      get :index

      expect(response.body).to eq("5")
    end
  end
end
