FactoryGirl.define do
  factory :country, class: Solidus::Country do
    iso_name 'UNITED STATES'
    name 'United States of America'
    iso 'US'
    iso3 'USA'
    numcode 840
  end
end
