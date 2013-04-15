require 'spec_helper'

describe "Product Translations tab" do
  let(:product) { create(:product) }

  stub_authorization!
  
  before do
    visit spree.admin_product_path(product)
  end

  it "clicks on translation tab" do
    click_on "Translations"
  end
end
