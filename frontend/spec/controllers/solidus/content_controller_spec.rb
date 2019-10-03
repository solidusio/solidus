# frozen_string_literal: true

require 'spec_helper'
describe Solidus::ContentController, type: :controller do
  it "should display CVV page" do
    get :cvv
    expect(response.response_code).to eq(200)
  end
end
