# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Spree::UsersController, type: :controller do
  let(:user) { Spree.user_class.new }

  describe '#show' do
    context 'when not authenticated' do
      before { allow(Spree.user_class).to receive(:find_by) { nil } }

      it 'redirects to unauthorized path' do
        get :show
        expect(response).to redirect_to '/unauthorized'
      end
    end

    context 'when authenticated' do
      before { allow(Spree.user_class).to receive(:find_by) { user } }

      it 'redirects to signup path if user is not found' do
        get :show
        expect(response).to be_successful
      end
    end
  end
end
