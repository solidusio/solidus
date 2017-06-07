require 'carmen'

# These countries have subregions, but typically don't use them in postal
# addresses.
COUNTRIES_THAT_DONT_REQUIRE_STATES = %w(NZ)

def require_states?(country)
  return false if COUNTRIES_THAT_DONT_REQUIRE_STATES.include? country.alpha_2_code
  country.subregions?
end

ActiveRecord::Base.transaction do
  Carmen::Country.all.each do |country|
    Spree::Country.where(iso: country.alpha_2_code).first_or_create!(
      name: country.name,
      iso3: country.alpha_3_code,
      iso_name: country.name.upcase,
      numcode: country.numeric_code,
      states_required: require_states?(country)
    )
  end
end
