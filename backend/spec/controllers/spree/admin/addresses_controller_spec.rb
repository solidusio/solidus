# frozen_string_literal: true

require 'spec_helper'
require 'pry'

describe Spree::Admin::AddressesController, type: :controller do
  let(:user) { create(:user) }

  let(:state) { create(:state, state_code: 'NY') }
  let(:valid_address_attributes) do
    {
      name: 'Foo Bar',
      city: "New York",
      country_id: state.country.id,
      state_id: state.id,
      phone: '555-555-5555',
      address1: '123 Fake St.',
      zipcode: '10001',
    }
  end

  let(:invalid_address_attributes) do
    {
      name: '',
      city: "Minsk",
      country_id: state.country.id,
      state_id: state.id,
      phone: '555-555-5555',
      address1: '123 Fake St.',
      zipcode: '10001',
    }
  end

  describe "#address" do
    let(:dummy_role) { Spree::Role.create(name: "dummyrole") }
    let(:ability) { Spree::Ability.new(user) }

    stub_authorization! do |_user|
      can :manage, Spree.user_class
    end

    it "can update ship and bill address attributes" do
      put :update, params: { user_id: user.id, user: { bill_address_attributes: valid_address_attributes, ship_address_attributes: valid_address_attributes }}
      expect(user.reload.ship_address.city).to eq('New York')
    end

    describe "can't update ship and bill addresses attributes" do
      it "name field is empty" do
        put :update, params: { user_id: user.id, user: { bill_address_attributes: valid_address_attributes, ship_address_attributes: invalid_address_attributes }}
        expect(user.reload.ship_address).nil?
      end
    end
  end
end
