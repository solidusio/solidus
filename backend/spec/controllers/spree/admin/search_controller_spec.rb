# frozen_string_literal: true

require 'spec_helper'

describe Spree::Admin::SearchController, type: :controller do
  stub_authorization!

  # Regression test for ernie/ransack#176
  let(:user) { create(:user, email: "spree_commerce@example.com") }

  before do
    user.ship_address = create(:address)
    user.bill_address = create(:address)
    user.save
  end

  describe 'GET #users' do
    subject { get :users, params: params, as: :json }

    shared_examples_for 'user found by search' do
      it "should include users matching query" do
        subject
        expect(assigns[:users]).to include(user)
      end
    end

    context 'when searching by user attributes' do
      let(:params) { { q: search_query } }

      def starting_letters(string)
        string.first(3)
      end

      context 'when searching by email' do
        it_should_behave_like 'user found by search' do
          let(:search_query) { starting_letters(user.email) }
        end
      end

      context 'when searching by ship addresss name' do
        it_should_behave_like 'user found by search' do
          let(:search_query) { starting_letters(user.ship_address.name) }
        end
      end

      context 'when searching by bill address name' do
        it_should_behave_like 'user found by search' do
          let(:search_query) { starting_letters(user.bill_address.name) }
        end
      end
    end

    context 'when searching by user ids' do
      let(:params) { { ids: user.id.to_s } }
      it_should_behave_like 'user found by search'
    end
  end

  describe 'get #products' do
    let!(:product_one) { create(:product, name: 'jersey') }
    let!(:product_two) { create(:product, name: 'better jersey') }

    subject { get :products, params: params, as: :json }

    shared_examples_for 'product search' do
      it 'should respond with http success' do
        subject
        expect(response).to be_successful
      end

      it 'should set the Surrogate-Control header' do
        subject
        expect(response.headers['Surrogate-Control']).to eq 'max-age=900'
      end

      it 'should find the correct products' do
        subject
        expect(assigns(:products)).to match_array expected_products
      end
    end

    context 'when ids param is present' do
      let(:params) { { ids: product_one.id } }

      it_should_behave_like 'product search' do
        let(:expected_products) { [product_one] }
      end
    end

    context 'when idds param is not present' do
      let(:params) { { q: { name_cont: 'jersey' } } }

      it_should_behave_like 'product search' do
        let(:expected_products) { [product_one, product_two] }
      end
    end
  end
end
