# frozen_string_literal: true

RSpec.shared_examples_for 'CRUD resource requests' do |resource_name, except: []|
  let(:admin_user) { create(:admin_user) }
  let(:resource) { create(factory) }

  # Overridables
  let(:factory) { resource_name.to_sym }
  let(:url_helpers) { solidus_admin }

  let(:resources_path) { url_helpers.public_send("#{resource_name.pluralize}_path") }
  let(:new_resource_path) { url_helpers.public_send("new_#{resource_name}_path") }
  let(:edit_resource_path) { url_helpers.public_send("edit_#{resource_name}_path", resource) }
  let(:resource_path) { url_helpers.public_send("#{resource_name}_path", resource) }

  let(:expected_after_create_path) { resources_path }
  let(:expected_after_update_path) { resources_path }
  let(:expected_after_destroy_path) { resources_path }

  before do
    allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(admin_user)
  end

  describe "GET /index", skip: :index.in?(except) && "not applicable" do
    it "renders the index template with a 200 OK status" do
      get resources_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /new", skip: :new.in?(except) && "not applicable" do
    it "renders the new template with a 200 OK status" do
      get new_resource_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /create", skip: :create.in?(except) && "not applicable" do
    context "with valid parameters" do
      it "creates a new #{resource_name.humanize}" do
        expect {
          post resources_path, params: { resource_name => valid_attributes }
        }.to change(resource_class, :count).by(1)
      end

      it "redirects with a 303 See Other status" do
        post resources_path, params: { resource_name => valid_attributes }
        expect(response).to redirect_to(expected_after_create_path)
        expect(response).to have_http_status(:see_other)
      end

      it "displays a success flash message" do
        post resources_path, params: { resource_name => valid_attributes }
        follow_redirect!
        expect(response.body).to include("#{resource_name.humanize} was successfully created.")
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { name: "", code: "", active: true } }

      it "does not create a new #{resource_name.humanize}" do
        expect {
          post resources_path, params: { resource_name => invalid_attributes }
        }.not_to change(resource_class, :count)
      end

      it "renders the new template with unprocessable_entity status" do
        post resources_path, params: { resource_name => invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /edit", skip: :edit.in?(except) && "not applicable" do
    it "renders the edit template with a 200 OK status" do
      get edit_resource_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /update", skip: :update.in?(except) && "not applicable" do
    context "with valid parameters" do
      it "updates the #{resource_name.humanize}" do
        patch resource_path, params: { resource_name => valid_attributes }
        resource.reload
        valid_attributes.each do |attr, value|
          expect(resource.public_send(attr)).to eq(value)
        end
      end

      it "redirects with a 303 See Other status" do
        patch resource_path, params: { resource_name => valid_attributes }
        expect(response).to redirect_to(expected_after_update_path)
        expect(response).to have_http_status(:see_other)
      end

      it "displays a success flash message" do
        patch resource_path, params: { resource_name => valid_attributes }
        follow_redirect!
        expect(response.body).to include("#{resource_name.humanize} was successfully updated.")
      end
    end

    context "with invalid parameters" do
      it "does not update the #{resource_name.humanize}" do
        expect {
          patch resource_path, params: { resource_name => invalid_attributes }
        }.not_to change { resource.reload }
      end

      it "renders the edit template with unprocessable_entity status" do
        patch resource_path, params: { resource_name => invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /destroy single", skip: :destroy_single.in?(except) && "not applicable" do
    it "deletes the #{resource_name.humanize} and redirects with a 303 See Other status" do
      # This ensures resource exists prior to deletion.
      resource
      expect { delete resource_path }.to change(resource_class, :count).by(-1)

      expect(response).to redirect_to(expected_after_destroy_path)
      expect(response).to have_http_status(:see_other)
    end

    it "displays a success flash message after deletion" do
      delete resource_path
      follow_redirect!
      expect(response.body).to include("#{resource_name.humanize.pluralize} were successfully removed.")
    end
  end

  describe "DELETE /destroy bulk", skip: :destroy_bulk.in?(except) && "not applicable" do
    it 'allows to bulk delete resources' do
      ids = [create(factory), create(factory)].map(&:id)
      expect { delete resources_path, params: { id: ids } }.to change { resource_class.count }.by(-ids.size)

      expect(response).to redirect_to(expected_after_destroy_path)
      expect(response).to have_http_status(:see_other)
    end
  end
end
