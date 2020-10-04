# frozen_string_literal: true

require 'spec_helper'

describe Spree::Admin::PromotionsController, type: :controller do
  stub_authorization!

  let!(:promotion1) { create(:promotion, name: "name1", code: "code1", path: "path1") }
  let!(:promotion2) { create(:promotion, name: "name2", code: "code2", path: "path2") }
  let!(:promotion3) { create(:promotion, name: "name2", code: "code3", path: "path3", expires_at: Date.yesterday) }
  let!(:category) { create :promotion_category }

  describe "#show" do
    it "redirects to edit" do
      expect(get(:show, params: { id: promotion1.id }))
        .to redirect_to(action: :edit, id: promotion1.id )
    end
  end

  describe "#index" do
    it "succeeds" do
      get :index
      expect(assigns[:promotions]).to match_array [promotion3, promotion2, promotion1]
    end

    it "assigns promotion categories" do
      get :index
      expect(assigns[:promotion_categories]).to match_array [category]
    end

    context "search" do
      it "pages results" do
        get :index, params: { per_page: '1' }
        expect(assigns[:promotions]).to eq [promotion3]
      end

      it "filters by name" do
        get :index, params: { q: { name_cont: promotion1.name } }
        expect(assigns[:promotions]).to eq [promotion1]
      end

      it "filters by code" do
        get :index, params: { q: { codes_value_cont: promotion1.codes.first.value } }
        expect(assigns[:promotions]).to eq [promotion1]
      end

      it "filters by path" do
        get :index, params: { q: { path_cont: promotion1.path } }
        expect(assigns[:promotions]).to eq [promotion1]
      end

      it "filters by active" do
        get :index, params: { q: { active: true } }
        expect(assigns[:promotions]).to match_array [promotion2, promotion1]
      end
    end
  end

  describe "#create" do
    subject { post :create, params: params }
    let(:params) { { promotion: { name: 'some promo' } } }

    context "it succeeds" do
      context "with no single code param" do
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

        it "doesn't create any promotion codes" do
          expect { subject }.to_not change { Spree::PromotionCode.count }
        end
      end

      context "with a single code" do
        let(:params) { { promotion: { name: 'some promo' }, single_code: "promo" } }

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

        it "creates a promotion code" do
          expect { subject }.to change { Spree::PromotionCode.count }.by(1)
          expect(Spree::PromotionCode.last.value).to eq("promo")
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
