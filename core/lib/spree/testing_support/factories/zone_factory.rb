# frozen_string_literal: true

require 'spree/testing_support'
Spree::TestingSupport.deprecate_cherry_picking_factory_bot_files

FactoryBot.define do
  factory :global_zone, class: 'Spree::Zone' do
    initialize_with { Spree::Zone.find_or_initialize_by(name: 'GlobalZone') }
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
