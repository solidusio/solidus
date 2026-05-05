# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'Home layout', type: :request, with_signed_in_user: true do
  let(:searcher_class) { instance_double(Spree::Config.searcher_class) }
  let(:user) { create(:user) }
  let(:product) { build_stubbed(:product) }
  let(:variant) { create(:variant) }
  let!(:featured_product) { create(:product, name: 'Solidus hoodie', variants: [variant] )}

  before do
    allow(Spree::Config.searcher_class).to receive(:new) { searcher_class }
    allow(searcher_class).to receive(:current_user=)
    allow(searcher_class).to receive(:pricing_options=)
    allow(searcher_class).to receive(:retrieve_products) { Spree::Product.where(id: product.id) }
  end

  it "provides current user to the searcher class" do
    get root_path
    expect(searcher_class).to have_received(:current_user=).with(user)
    expect(response.status).to eq(200)
  end

  context "layout" do
    it "renders default layout" do
      get root_path
      expect(response).to render_template(layout: 'layouts/storefront')
    end
  end
end
