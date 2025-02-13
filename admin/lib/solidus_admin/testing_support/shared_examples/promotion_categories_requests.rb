# frozen_string_literal: true

RSpec.shared_examples_for 'promotion categories requests' do
  let(:admin_user) { create(:admin_user) }

  before do
    allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(admin_user)
  end

  describe "GET /index" do
    it "renders the index template with a 200 OK status" do
      get url_helpers.promotion_categories_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /new" do
    it "renders the new template with a 200 OK status" do
      get url_helpers.new_promotion_category_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      let(:valid_attributes) { { name: "Expired", code: "exp.1" } }
      let(:run_request) { post url_helpers.promotion_categories_path, params: { promotion_category: valid_attributes } }

      it "creates a new promotion category" do
        expect { run_request }.to change(model_class, :count).by(1)
      end

      it "redirects to the index page with a 303 See Other status" do
        run_request
        expect(response).to redirect_to(url_helpers.promotion_categories_path)
        expect(response).to have_http_status(:see_other)
      end

      it "displays a success flash message" do
        run_request
        follow_redirect!
        expect(response.body).to include("Promotion Category was successfully created.")
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { name: "", code: "" } }
      let(:run_request) { post url_helpers.promotion_categories_path, params: { promotion_category: invalid_attributes } }

      it "does not create a new promotion category" do
        expect { run_request }.not_to change(model_class, :count)
      end

      it "renders the new template with unprocessable_entity status" do
        run_request
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /edit" do
    it "renders the edit template with a 200 OK status" do
      get url_helpers.edit_promotion_category_path(promotion_category)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:valid_attributes) { { name: "Updated", code: "upd.1" } }
      let(:run_request) { patch url_helpers.promotion_category_path(promotion_category), params: { promotion_category: valid_attributes } }

      it "updates the promotion category" do
        run_request
        promotion_category.reload
        expect(promotion_category.name).to eq("Updated")
        expect(promotion_category.code).to eq("upd.1")
      end

      it "redirects to the index page with a 303 See Other status" do
        run_request
        expect(response).to redirect_to(url_helpers.promotion_categories_path)
        expect(response).to have_http_status(:see_other)
      end

      it "displays a success flash message" do
        run_request
        follow_redirect!
        expect(response.body).to include("Promotion Category was successfully updated.")
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { name: "", code: "" } }
      let(:run_request) { patch url_helpers.promotion_category_path(promotion_category), params: { promotion_category: invalid_attributes } }

      it "does not update the promotion category" do
        expect { run_request }.not_to change { promotion_category.reload.name }
      end

      it "renders the edit template with unprocessable_entity status" do
        run_request
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /destroy" do
    before { promotion_category }

    let(:run_request) { delete url_helpers.promotion_category_path(promotion_category) }

    it "deletes the promotion category and redirects to the index page with a 303 See Other status" do
      expect { run_request }.to change(model_class, :count).by(-1)

      expect(response).to redirect_to(url_helpers.promotion_categories_path)
      expect(response).to have_http_status(:see_other)
    end

    it "displays a success flash message after deletion" do
      run_request
      follow_redirect!
      expect(response.body).to include("Promotion Categories were successfully removed.")
    end
  end
end
