# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/factories/user_factory'

RSpec.describe 'user factory' do
  let(:factory_class) { Spree.user_class }

  describe 'user' do
    let(:factory) { :user }

    it_behaves_like 'a working factory'
  end
  describe 'admin user' do
    let(:factory) { :admin_user }

    it_behaves_like 'a working factory'
  end
  describe 'user with addresses' do
    let(:factory) { :user_with_addresses }

    it_behaves_like 'a working factory'
  end
end
