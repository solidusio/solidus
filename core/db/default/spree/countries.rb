require 'carmen'

ActiveRecord::Base.transaction do
  Carmen::Country.all.each do |country|
    Spree::Country.where(iso: country.alpha_2_code).first_or_create!(
      name: country.name,
      iso3: country.alpha_3_code,
      iso_name: country.name.upcase,
      numcode: country.numeric_code,
      states_required: country.subregions?
    )
  end
end
