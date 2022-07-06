# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.when_cherry_picked do
  Spree::TestingSupport::FactoryBot.deprecate_cherry_picking

  require 'spree/testing_support/factories/state_factory'
  require 'spree/testing_support/factories/country_factory'
end
FactoryBot.define do
  factory :address, class: 'Spree::Address' do
    transient do
      # There's `Spree::Address#country_iso=`, prohibiting me from using `country_iso` here
      country_iso_code { 'US' }
      state_code { 'AL' }
    end

    name { 'John Von Doe' }
    company { 'Company' }
    address1 { '10 Lovely Street' }
    address2 { 'Northwest' }
    city { 'Herndon' }
    sequence(:zipcode, 10001) { |i| i.to_s }
    phone { '555-555-0199' }
    alternative_phone { '555-555-0199' }

    country do |address|
      if address.state
        address.state.country
      else
        Spree::Country.find_by(iso: country_iso_code) ||
          address.association(:country, strategy: :create, iso: country_iso_code)
      end
    end

    after(:build) do |address, evaluator|
      if address&.country&.states_required? && address.state.nil? && address.state_name.nil?
        address.state = address.country.states.find_by(abbr: evaluator.state_code) ||
          create(:state, country_iso: address.country.iso, state_code: evaluator.state_code)
      end
    end
  end

  factory :ship_address, parent: :address do
    address1 { 'A Different Road' }
  end

  factory :bill_address, parent: :address do
    address1 { 'PO Box 1337' }
  end
end
