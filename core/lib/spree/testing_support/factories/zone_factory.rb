# frozen_string_literal: true

require 'spree/testing_support/sequences'
require 'spree/testing_support/factories/country_factory'

FactoryBot.define do
  factory :global_zone, class: 'Spree::Zone' do
    name { 'GlobalZone' }
    zone_members do |proxy|
      zone = proxy.instance_eval { @instance }
      Spree::Country.all.map do |c|
        Spree::ZoneMember.create(zoneable: c, zone: zone)
      end
    end
  end

  factory :zone, class: 'Spree::Zone' do
    sequence(:name) { |i| "Zone #{i}" }

    trait :with_country do
      countries { [create(:country)] }
    end
  end
end
