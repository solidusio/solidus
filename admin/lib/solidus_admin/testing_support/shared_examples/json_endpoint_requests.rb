# frozen_string_literal: true

RSpec.shared_examples_for "JSON endpoint requests" do |method:, admin_path:|
  # Overridable context.
  let(:path_params) { {} }
  let(:request_params) { {} }

  before do
    allow_any_instance_of(SolidusAdmin::BaseController)
      .to receive(:spree_current_user)
      .and_return(user)
  end

  let(:path) { solidus_admin.public_send(admin_path, **path_params) }

  describe "JSON endpoint requests (shared examples)", type: :request do
    subject {
      path = solidus_admin.public_send(admin_path, **path_params)
      public_send(method, path, params: request_params)
      response
    }

    context "when unauthenticated" do
      let(:user) { nil }

      it "responds as unauthorized" do
        expect(subject).to have_http_status :unauthorized
      end

      it "responds in JSON format" do
        expect(subject.content_type).to match(/^application\/json/)
      end
    end

    context "when authenticated as any user" do
      let(:user) { create :user }

      it "responds as forbidden" do
        expect(subject).to have_http_status :forbidden
      end

      it "responds in JSON format" do
        expect(subject.content_type).to match(/^application\/json/)
      end
    end

    context "when authenticated as an admin user" do
      let(:user) { create :admin_user }

      it "responds in JSON format" do
        expect(subject.content_type).to match(/^application\/json/)
      end

      it "serves JSON with a 200 OK status" do
        expect(subject).to have_http_status(:ok)
      end
    end
  end
end
