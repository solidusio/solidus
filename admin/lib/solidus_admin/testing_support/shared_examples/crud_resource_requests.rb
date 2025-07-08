# frozen_string_literal: true

RSpec.shared_examples_for 'CRUD resource requests' do |resource_name|
  let(:admin_user) { create(:admin_user) }
  let(:resource) { create(factory) }

  # Overridables
  let(:factory) { resource_name.to_sym }
  let(:url_helpers) { solidus_admin }

  before do
    allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(admin_user)
  end

  describe "GET /index" do
    it "renders the index template with a 200 OK status" do
      get url_helpers.public_send("#{resource_name.pluralize}_path")
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /new" do
    it "renders the new template with a 200 OK status" do
      get url_helpers.public_send("new_#{resource_name}_path")
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new #{resource_name.humanize}" do
        expect {
          post url_helpers.public_send("#{resource_name.pluralize}_path"), params: { resource_name => valid_attributes }
        }.to change(resource_class, :count).by(1)
      end

      it "redirects to the index page with a 303 See Other status" do
        post url_helpers.public_send("#{resource_name.pluralize}_path"), params: { resource_name => valid_attributes }
        expect(response).to redirect_to(url_helpers.public_send("#{resource_name.pluralize}_path"))
        expect(response).to have_http_status(:see_other)
      end

      it "displays a success flash message" do
        post url_helpers.public_send("#{resource_name.pluralize}_path"), params: { resource_name => valid_attributes }
        follow_redirect!
        expect(response.body).to include("#{resource_name.humanize} was successfully created.")
      end
    end

    context "with invalid parameters" do
      it "does not create a new #{resource_name.humanize}" do
        expect {
          post url_helpers.public_send("#{resource_name.pluralize}_path"), params: { resource_name => invalid_attributes }
        }.not_to change(resource_class, :count)
      end

      it "renders the new template with unprocessable_entity status" do
        post url_helpers.public_send("#{resource_name.pluralize}_path"), params: { resource_name => invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /edit" do
    it "renders the edit template with a 200 OK status" do
      get url_helpers.public_send("edit_#{resource_name}_path", resource)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      it "updates the #{resource_name.humanize}" do
        patch url_helpers.public_send("#{resource_name}_path", resource), params: { resource_name => valid_attributes }
        resource.reload
        valid_attributes.each do |attr, value|
          expect(resource.public_send(attr)).to eq(value)
        end
      end

      it "redirects to the index page with a 303 See Other status" do
        patch url_helpers.public_send("#{resource_name}_path", resource), params: { resource_name => valid_attributes }
        expect(response).to redirect_to(url_helpers.public_send("#{resource_name.pluralize}_path"))
        expect(response).to have_http_status(:see_other)
      end

      it "displays a success flash message" do
        patch url_helpers.public_send("#{resource_name}_path", resource), params: { resource_name => valid_attributes }
        follow_redirect!
        expect(response.body).to include("#{resource_name.humanize} was successfully updated.")
      end
    end

    context "with invalid parameters" do
      it "does not update the #{resource_name.humanize}" do
        expect {
          patch url_helpers.public_send("#{resource_name}_path", resource), params: { resource_name => invalid_attributes }
        }.not_to change { resource.reload }
      end

      it "renders the edit template with unprocessable_entity status" do
        patch url_helpers.public_send("#{resource_name}_path", resource), params: { resource_name => invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /destroy" do
    it "deletes the #{resource_name.humanize} and redirects to the index page with a 303 See Other status" do
      # This ensures resource exists prior to deletion.
      resource
      expect {
        delete url_helpers.public_send("#{resource_name}_path", resource)
      }.to change(resource_class, :count).by(-1)

      expect(response).to redirect_to(url_helpers.public_send("#{resource_name.pluralize}_path"))
      expect(response).to have_http_status(:see_other)
    end

    it "displays a success flash message after deletion" do
      delete url_helpers.public_send("#{resource_name}_path", resource)
      follow_redirect!
      expect(response.body).to include("#{resource_name.humanize.pluralize} were successfully removed.")
    end

    it 'allows to bulk delete resources' do
      ids = [create(factory), create(factory)].map(&:id)
      expect {
        delete url_helpers.public_send("#{resource_name.pluralize}_path", id: ids)
      }.to change { resource_class.count }.by(-ids.size)

      expect(response).to redirect_to(url_helpers.public_send("#{resource_name.pluralize}_path"))
      expect(response).to have_http_status(:see_other)
    end
  end
end
