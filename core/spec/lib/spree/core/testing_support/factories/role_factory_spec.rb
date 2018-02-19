# frozen_string_literal: true

require 'rails_helper'
require 'spree/testing_support/factories/role_factory'

RSpec.describe 'role factory' do
  let(:factory_class) { Spree::Role }

  describe 'plain role' do
    let(:factory) { :role }

    it_behaves_like 'a working factory'
  end

  describe 'admin role' do
    let(:factory) { :admin_role }

    it_behaves_like 'a working factory'
  end
end
