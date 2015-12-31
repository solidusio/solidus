ActiveRecord::Base.transaction do
  Solidus::Country.all.each do |country|
    carmen_country = Carmen::Country.named(country.name)
    @states ||= []
    if carmen_country.subregions?
      carmen_country.subregions.each do |subregion|
        @states << {
          name: subregion.name,
          abbr: subregion.code,
          country: country
        }
      end
    end
  end
  Solidus::State.create!(@states)
end
