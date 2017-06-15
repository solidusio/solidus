require 'spec_helper'

describe Spree::CurrentStoreSelector do
  describe "#store" do
    subject { Spree::CurrentStoreSelector.new(request).store }

    context "with a default" do
      let(:request) { double('any request') }
      let!(:store_1) { create :store, default: true }

      it "returns the default store" do
        expect(subject).to eq(store_1)
      end
    end
  end
end
