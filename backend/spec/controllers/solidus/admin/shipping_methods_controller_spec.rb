require 'spec_helper'

describe Solidus::Admin::ShippingMethodsController, :type => :controller do
  stub_authorization!

  # Regression test for #1240
  it "should not hard-delete shipping methods" do
    shipping_method = stub_model(Solidus::ShippingMethod)
    allow(Solidus::ShippingMethod).to receive_messages :find => shipping_method
    expect(shipping_method.deleted_at).to be_nil
    solidus_delete :destroy, :id => 1
    expect(shipping_method.reload.deleted_at).not_to be_nil
  end
end
