# frozen_string_literal: true

def create_states(subregions, country)
  subregions.each do |subregion|
    Spree::State.where(abbr: subregion.code, country: country).first_or_create!(
      name: subregion.name
    )
  end
end

ActiveRecord::Base.transaction do
  Spree::Country.all.each do |country|
    carmen_country = Carmen::Country.coded(country.iso)
    next unless carmen_country.subregions?

    if Spree::Config[:countries_that_use_nested_subregions].include? country.iso
      create_states(carmen_country.subregions.flat_map(&:subregions), country)
    else
      create_states(carmen_country.subregions, country)
    end
  end
end
