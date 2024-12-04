# frozen_string_literal: true

require "spec_helper"
require "spree/core"
require "spree/user_class_handle"

RSpec.describe Spree::UserClassHandle do
  describe "#to_s" do
    around do |example|
      @prev_user_class = Spree.user_class_name
      example.run
      Spree.user_class = @prev_user_class
    end

    subject { described_class.new.to_s }

    context "when Spree.user_class is nil" do
      before do
        Spree.user_class = nil
      end

      it "is expected to fail" do
        expect { subject }.to raise_error(RuntimeError, "'Spree.user_class' has not been set yet.")
      end
    end

    context "when Spree.user_class is not nil" do
      before do
        Spree.user_class = "Spree::User"
      end

      it "is expected to return the user class as a string" do
        expect(subject).to eq("::Spree::User")
      end
    end
  end
end
