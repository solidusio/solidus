require 'spec_helper'

module Spree
  describe ProductsController do
    let!(:product) { create(:product) }

    before { controller.stub(config_locale: :'pt-BR') }

    context "visit non translated product page via permalink on url" do
      it "displays pages successfully" do
        spree_get :show, id: product.permalink
        expect(response).to be_success
      end
    end
  end
end
