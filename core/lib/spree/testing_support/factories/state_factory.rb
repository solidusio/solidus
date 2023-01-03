# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.when_cherry_picked do
  Spree::TestingSupport::FactoryBot.deprecate_cherry_picking

  require 'spree/testing_support/factories/country_factory'
end

FactoryBot.define do
  factory :state, class: 'Spree::State' do
    transient do
      country_iso { 'US' }
      state_code { 'AL' }

      carmen_subregion do
        carmen_country = Carmen::Country.coded(country.iso)

        unless carmen_country.subregions?
          fail("Country #{country.iso} has no subregions")
        end

        carmen_regions = carmen_country.subregions
        carmen_regions = carmen_regions.flat_map(&:subregions) if carmen_regions.first.subregions?
        region_collection = Carmen::RegionCollection.new(carmen_regions)

        region_collection.coded(state_code) || region_collection.sort_by(&:name).first
      end
    end

    abbr { carmen_subregion.code }
    name { carmen_subregion.name }

    country do |country|
      Spree::Country.find_by(iso: country_iso) ||
        country.association(:country, iso: country_iso)
    end
  end
end

