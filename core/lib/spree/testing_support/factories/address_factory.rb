require 'spree/testing_support/factories/state_factory'
require 'spree/testing_support/factories/country_factory'

FactoryGirl.define do
  factory :address, class: Spree::Address do
    firstname 'John'
    lastname 'Doe'
    company 'Company'
    address1 '10 Lovely Street'
    address2 'Northwest'
    city 'Herndon'
    zipcode '35005'
    phone '555-555-0199'
    alternative_phone '555-555-0199'

    state { |address| address.association(:state) }
    country do |address|
      if address.state
        address.state.country
      else
        address.association(:country)
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
