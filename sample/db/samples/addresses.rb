# frozen_string_literal: true

united_states = Spree::Country.find_by!(iso: "US")
new_york = Spree::State.find_by!(name: "New York")

first_names = ["Sterling", "Jennette", "Salome", "Lyla", "Lola", "Cheree",
               "Hettie", "Barbie", "Amelia", "Marceline", "Keeley", "Mi",
               "Karon", "Jessika", "Emmy"]
last_names = ["Torp", "Vandervort", "Stroman", "Lang", "Zulauf", "Bruen",
              "Torp", "Gutmann", "Renner", "Bergstrom", "Sauer", "Gaylord",
              "Mills", "Daugherty", "Stark"]
street_addresses = ["7377 Jacobi Passage", "4725 Serena Ridges",
                    "79832 Hamill Creek", "0746 Genoveva Villages",
                    "86717 D'Amore Hollow", "8529 Delena Well",
                    "959 Lockman Ferry", "67016 Murphy Fork",
                    "193 Larkin Divide", "80697 Cole Parks"]
secondary_addresses = ["Suite 918", "Suite 374", "Apt. 714", "Apt. 351",
                       "Suite 274", "Suite 240", "Suite 892", "Apt. 176",
                       "Apt. 986", "Apt. 583"]
cities = ["Lake Laurenceview", "Lucilefurt", "South Jannetteport",
          "Leannonport", "Legrosburgh", "Willmsberg", "Karoleside",
          "Lake German", "Keeblerfort", "Lemkehaven"]
phone_numbers = ["(392)859-7319 x670", "738-831-3210 x6047",
                 "(441)881-8127 x030", "1-744-701-0536 x30504",
                 "(992)432-8273 x97676", "482.249.0178 x532",
                 "(855)317-6523", "1-529-214-7315 x90865",
                 "(662)877-7894 x703", "689.578.8564 x72399"]

2.times do
  Spree::Address.create!(
    firstname: first_names.sample,
    lastname: last_names.sample,
    address1: street_addresses.sample,
    address2: secondary_addresses.sample,
    city: cities.sample,
    state: new_york,
    zipcode: 16_804,
    country: united_states,
    phone: phone_numbers.sample
  )
end
