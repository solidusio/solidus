# frozen_string_literal: true

require 'spec_helper'

describe Spree::Admin::ShippingMethodsController, type: :controller do
  stub_authorization!

  # Regression test for https://github.com/spree/spree/issues/1240
  it "should not hard-delete shipping methods" do
    shipping_method = create(:shipping_method)

    delete :destroy, params: { id: shipping_method.id }

    expect(shipping_method.reload.deleted_at).not_to be_nil
  end
end
