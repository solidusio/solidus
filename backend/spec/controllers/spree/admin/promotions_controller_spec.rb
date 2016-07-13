require 'spec_helper'

describe Spree::Admin::PromotionsController, type: :controller do
  stub_authorization!

  let!(:promotion1) { create(:promotion, name: "name1", code: "code1", path: "path1") }
  let!(:promotion2) { create(:promotion, name: "name2", code: "code2", path: "path2") }
  let!(:category) { create :promotion_category }

  describe "#index" do
    it "succeeds" do
      get :index
      expect(assigns[:promotions]).to match_array [promotion2, promotion1]
    end

    it "assigns promotion categories" do
      get :index
      expect(assigns[:promotion_categories]).to match_array [category]
    end

    context "search" do
      it "pages results" do
        get :index, per_page: '1'
        expect(assigns[:promotions]).to eq [promotion2]
      end

      it "filters by name" do
        get :index, q: { name_cont: promotion1.name }
        expect(assigns[:promotions]).to eq [promotion1]
      end

      it "filters by code" do
        get :index, q: { codes_value_cont: promotion1.codes.first.value }
        expect(assigns[:promotions]).to eq [promotion1]
      end

      it "filters by path" do
        get :index, q: { path_cont: promotion1.path }
        expect(assigns[:promotions]).to eq [promotion1]
      end
    end
  end

  describe "#create" do
    subject { post :create, params }
    let(:params) { { promotion: { name: 'some promo' } } }

    context "it succeeds" do
      it "creates a promotion" do
        expect { subject }.to change { Spree::Promotion.count }.by(1)
      end

      it "sets the flash message" do
        subject
        expect(flash[:success]).to eq "Promotion has been successfully created!"
      end

      it "redirects to promotion edit" do
        subject
        expect(response).to redirect_to "http://test.host/admin/promotions/#{assigns(:promotion).id}/edit"
      end

      context "with one promo codes" do
        let(:params) do
          super().merge(promotion_builder: { base_code: 'abc', number_of_codes: 1 })
        end

        it "succeeds and creates one code" do
          expect {
            expect {
              subject
            }.to change { Spree::Promotion.count }.by(1)
          }.to change { Spree::PromotionCode.count }.by(1)

          expect(assigns(:promotion).codes.first.value).to eq 'abc'
        end
      end

      context "with multiple promo codes" do
        let(:params) do
          super().merge(promotion_builder: { base_code: 'abc', number_of_codes: 2 })
        end

        it "succeeds and creates multiple codes" do
          expect {
            expect {
              subject
            }.to change { Spree::Promotion.count }.by(1)
          }.to change { Spree::PromotionCode.count }.by(2)

          codes = assigns(:promotion).codes.map(&:value).sort
          expect(codes.length).to be 2
          expect(codes[0]).to match(/abc_[a-z]{6}/)
          expect(codes[1]).to match(/abc_[a-z]{6}/)
        end
      end
    end

    context "it fails" do
      let(:params) { {} }

      it "does not create a promotion" do
        expect {
          subject
        }.not_to change { Spree::Promotion.count }
      end

      it "sets the flash error" do
        subject
        expect(flash[:error]).to eq "Name can't be blank"
      end

      it "renders new" do
        subject
        expect(response).to render_template :new
      end
    end
  end
end
