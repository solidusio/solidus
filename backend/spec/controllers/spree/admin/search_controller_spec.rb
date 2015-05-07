require 'spec_helper'

describe Spree::Admin::SearchController, :type => :controller do
  stub_authorization!

  # Regression test for ernie/ransack#176
  let(:user) { create(:user, email: "spree_commerce@example.com") }

  before do
    user.ship_address = create(:address)
    user.bill_address = create(:address)
    user.save
  end

  describe 'GET #users' do
    subject { spree_xhr_get :users, q: search_query }

    shared_examples_for 'user found by search' do
      it "should include users matching query" do
        subject
        expect(assigns[:users]).to include(user)
      end
    end

    context 'when searching by email' do
      it_should_behave_like 'user found by search' do
        let(:search_query) { user.email }
      end
    end

    context 'when searching by ship addresss first name' do
      it_should_behave_like 'user found by search' do
        let(:search_query) { user.ship_address.firstname }
      end
    end

    context 'when searching by ship address last name' do
      it_should_behave_like 'user found by search' do
        let(:search_query) { user.ship_address.lastname }
      end
    end

    context 'when searching by bill address first name' do
      it_should_behave_like 'user found by search' do
        let(:search_query) { user.bill_address.firstname }
      end
    end

    context 'when searching by bill address last name' do
      it_should_behave_like 'user found by search' do
        let(:search_query) { user.bill_address.firstname }
      end
    end
  end

end
