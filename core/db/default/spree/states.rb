# frozen_string_literal: true

ActiveRecord::Base.transaction do
  Spree::Country.all.each do |country|
    carmen_country = Carmen::Country.coded(country.iso)
    next unless carmen_country.subregions?

    carmen_country.subregions.each do |subregion|
      Spree::State.where(abbr: subregion.code, country: country).first_or_create!(
        name: subregion.name
      )
    end
  end
end
