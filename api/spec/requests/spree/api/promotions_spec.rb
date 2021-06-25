# frozen_string_literal: true

require 'spec_helper'

module Spree
  describe Spree::Api::PromotionsController, type: :request do
    shared_examples "a JSON response" do
      it 'should be ok' do
        subject
        expect(response).to be_ok
      end

      it 'should return JSON' do
        subject
        payload = HashWithIndifferentAccess.new(JSON.parse(response.body))
        expect(payload).to_not be_nil
        Spree::Api::ApiHelpers.promotion_attributes.each do |attribute|
          expect(payload).to be_has_key(attribute)
        end
      end
    end

    before do
      stub_authentication!
    end

    let(:promotion) { create :promotion, code: '10off' }

    describe 'GET #show' do
      subject { get spree.api_promotion_path(id) }

      context 'when admin' do
        sign_in_as_admin!

        context 'when finding by id' do
          let(:id) { promotion.id }

          it_behaves_like "a JSON response"
        end

        context 'when finding by code' do
          let(:id) { promotion.codes.first.value }

          it_behaves_like "a JSON response"
        end

        context 'when id does not exist' do
          let(:id) { 'argh' }

          it 'should be 404' do
            subject
            expect(response.status).to eq(404)
          end
        end
      end

      context 'when non admin' do
        let(:id) { promotion.id }

        it 'should be unauthorized' do
          subject
          assert_unauthorized!
        end
      end
    end
  end
end
