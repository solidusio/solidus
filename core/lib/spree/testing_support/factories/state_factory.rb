require 'spree/testing_support/factories/country_factory'

FactoryGirl.define do
  factory :state, class: Spree::State do
    transient do
      country_iso 'US'
      carmen_subregion do
        Carmen::Country.coded(country_iso).subregions.sort_by(&:name).first ||
          fail("Unknown country iso code or no Country has no subregions: #{country_iso.inspect}")
      end
    end

    abbr { carmen_subregion.code }
    name { carmen_subregion.name }

    country do |country|
      if usa = Spree::Country.find_by(iso: country_iso)
        country = usa
      else
        country.association(:country, iso: country_iso)
      end
    end
  end
end
