require 'spree/testing_support/factories/country_factory'

FactoryGirl.define do
  factory :state, class: Spree::State do
    transient do
      country_iso 'US'
      state_code 'AL'
      carmen_subregion do
        Carmen::Country.coded(country_iso).subregions.coded(state_code) ||
          Carmen::Country.coded(country_iso).subregions.sort_by(&:name).first ||
          fail("Unknown country iso code or no Country has no subregions: #{country_iso.inspect}")
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
