require 'spree/testing_support/factories/state_factory'
require 'spree/testing_support/factories/country_factory'
require 'twitter_cldr'

FactoryGirl.define do
  factory :address, class: Spree::Address do
    transient do
      # There's `Spree::Address#country_iso=`, prohibiting me from using `country_iso` here
      country_iso_code 'US'
    end

    firstname 'John'
    lastname 'Doe'
    company 'Company'
    address1 '10 Lovely Street'
    address2 'Northwest'
    city 'Herndon'
    zipcode { TwitterCldr::Shared::PostalCodes.for_territory(country_iso_code).sample.first }
    phone '555-555-0199'
    alternative_phone '555-555-0199'

    state { |address| address.association(:state, country_iso: country_iso_code) }
    country do |address|
      if address.state
        address.state.country
      else
        address.association(:country, iso: country_iso_code)
      end
    end
  end

  factory :ship_address, parent: :address do
    address1 'A Different Road'
  end

  factory :bill_address, parent: :address do
    address1 'PO Box 1337'
  end
end
