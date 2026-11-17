# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Errors on the resource itself", type: :request do
  let(:admin_user) { create(:admin_user) }
  let(:turbo_stream) { {"Accept" => "text/vnd.turbo-stream.html, text/html"} }
  # Created before stubbing the validation below.
  let!(:refund_reason) { create(:refund_reason) }

  before do
    allow_any_instance_of(SolidusAdmin::BaseController).to receive(:spree_current_user).and_return(admin_user)

    # Spree::RefundReason has no validation on :base, so add one for every save.
    allow_any_instance_of(Spree::RefundReason).to receive(:valid?) do |refund_reason|
      refund_reason.errors.add(:base, "Refunds are frozen")
      refund_reason.errors.add(:base, "Try again tomorrow")
      false
    end
  end

  it "shows them in an alert when the creation fails" do
    post solidus_admin.refund_reasons_path, params: {refund_reason: {name: "Defect", code: "DEF"}}

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include('id="flash_alerts"')
    expect(response.body).to include("Refunds are frozen\nTry again tomorrow")
  end

  it "shows them in an alert when the update fails" do
    patch solidus_admin.refund_reason_path(refund_reason), params: {refund_reason: {name: "Defect"}}

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include("Refunds are frozen\nTry again tomorrow")
  end

  it "replaces the alerts along with the form in turbo stream responses" do
    post solidus_admin.refund_reasons_path, params: {refund_reason: {name: "Defect", code: "DEF"}}, headers: turbo_stream

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.media_type).to eq("text/vnd.turbo-stream.html")
    expect(response.body).to include('<turbo-stream action="replace" target="resource_form">')
    expect(response.body).to include('<turbo-stream action="replace" target="flash_alerts">')
    expect(response.body).to include("Refunds are frozen")
  end

  it "does not touch the alerts when there are only errors on attributes" do
    allow_any_instance_of(Spree::RefundReason).to receive(:valid?).and_call_original

    post solidus_admin.refund_reasons_path, params: {refund_reason: {name: ""}}, headers: turbo_stream

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).not_to include('target="flash_alerts"')
  end
end
