require 'spec_helper'

describe Spree::Core::CurrentStore do
  describe "#store" do
    subject { Spree::Deprecation.silence { Spree::Core::CurrentStore.new(request).store } }

    context "with a default" do
      let(:request) { double('any request') }
      let!(:store_1) { create :store, default: true }

      it "returns the default store" do
        expect(subject).to eq(store_1)
      end
    end

    it 'is deprecated' do
      expect(Spree::Deprecation).to(receive(:warn))
      Spree::Core::CurrentStore.new(double)
    end
  end
end
