# frozen_string_literal: true

require 'solidus/testing_support/sequences'
require 'solidus/testing_support/factories/country_factory'

FactoryBot.define do
  factory :global_zone, class: 'Solidus::Zone' do
    name { 'GlobalZone' }
    zone_members do |proxy|
      zone = proxy.instance_eval { @instance }
      Solidus::Country.all.map do |c|
        Solidus::ZoneMember.create(zoneable: c, zone: zone)
      end
    end
  end

  factory :zone, class: 'Solidus::Zone' do
    sequence(:name) { |i| "Zone #{i}" }

    trait :with_country do
      countries { [create(:country)] }
    end
  end
end
