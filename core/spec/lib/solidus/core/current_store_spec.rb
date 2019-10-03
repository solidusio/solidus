# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solidus::Core::CurrentStore do
  describe "#store" do
    subject { Solidus::Deprecation.silence { Solidus::Core::CurrentStore.new(request).store } }

    context "with a default" do
      let(:request) { double(headers: {}, env: {}) }
      let!(:store_1) { create :store, default: true }

      it "returns the default store" do
        expect(subject).to eq(store_1)
      end

      context "with a domain match" do
        let(:request) { double(headers: {}, env: { "SERVER_NAME" => url } ) }
        let(:url) { "server-name.org" }
        let!(:store_2) { create :store, default: false, url: url }

        it "returns the store with the matching domain" do
          expect(subject).to eq(store_2)
        end
      end
    end

    it 'is deprecated' do
      expect(Solidus::Deprecation).to(receive(:warn))
      Solidus::Core::CurrentStore.new(double)
    end
  end
end
