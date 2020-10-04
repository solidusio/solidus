# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::PaymentMethod::SimpleBogusCreditCard, type: :model do
  subject { Spree::PaymentMethod::SimpleBogusCreditCard.new }

  # regression test for https://github.com/spree/spree/issues/3824
  describe "#capture" do
    it "returns success with the right response code" do
      response = subject.capture(123, '12345', {})
      expect(response.message).to include("success")
    end

    it "returns failure with the wrong response code" do
      response = subject.capture(123, 'wrong', {})
      expect(response.message).to include("failure")
    end
  end
end
