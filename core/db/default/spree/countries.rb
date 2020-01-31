# frozen_string_literal: true

require 'carmen'

# Insert Countries into the spree_countries table, checking to ensure that no
# duplicates are created, using as few SQL statements as possible (2)

connection = Spree::Base.connection

country_mapper = ->(country) do
  name            = connection.quote country.name
  iso3            = connection.quote country.alpha_3_code
  iso             = connection.quote country.alpha_2_code
  iso_name        = connection.quote country.name.upcase
  numcode         = connection.quote country.numeric_code
  states_required = connection.quote country.subregions?

  [name, iso3, iso, iso_name, numcode, states_required].join(", ")
end

country_values = -> do
  carmen_countries = Carmen::Country.all

  # find entires already in the database (so that we may ignore them)
  existing_country_isos =
    Spree::Country.where(iso: carmen_countries.map(&:alpha_2_code)).pluck(:iso)

  # create VALUES statements for each country _not_ already in the database
  carmen_countries
    .reject { |c| existing_country_isos.include?(c.alpha_2_code) }
    .map(&country_mapper)
    .join("), (")
end

country_columns = %w(name iso3 iso iso_name numcode states_required).join(', ')
country_vals = country_values.call

if country_vals.present?
  # execute raw SQL (insted of ActiveRecord.create) to use a single
  # INSERT statement, and to avoid any validations or callbacks
  connection.execute <<-SQL
    INSERT INTO spree_countries (#{country_columns})
    VALUES (#{country_vals});
  SQL
end
