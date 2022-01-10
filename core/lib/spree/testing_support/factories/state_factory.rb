require 'spree/testing_support/factories/country_factory'

FactoryBot.define do
  factory :state, class: Spree::State do
    transient do
      country_iso { 'US' }
      state_code { 'AL' }

      carmen_subregion do
        carmen_country = Carmen::Country.coded(country.iso)

        # TODO: This condition can be removed after this carmen update is
        # available: https://github.com/jim/carmen/pull/177
        if !carmen_country.subregions?
          fail("Country #{country.iso} has no subregions")
        end

        carmen_country.subregions.coded(state_code) ||
          carmen_country.subregions.sort_by(&:name).first ||
          fail("Country #{country.iso} has no subregions")
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
