module Spree
  RSpec.describe ProductsController, type: :controller do
    let!(:product) { create(:product) }

    before { allow(controller).to receive(:config_locale) { :'pt-BR' } }

    context "visit non translated product page via permalink on url" do
      it "displays pages successfully" do
        spree_get :show, id: product.slug
        expect(response).to be_success
      end
    end
  end
end
