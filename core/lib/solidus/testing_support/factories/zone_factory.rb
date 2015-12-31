FactoryGirl.define do
  factory :global_zone, class: Solidus::Zone do
    name 'GlobalZone'
    description { generate(:random_string) }
    zone_members do |proxy|
      zone = proxy.instance_eval { @instance }
      Solidus::Country.all.map do |c|
        zone_member = Solidus::ZoneMember.create(zoneable: c, zone: zone)
      end
    end
  end

  factory :zone, class: Solidus::Zone do
    name { generate(:random_string) }
    description { generate(:random_string) }

    trait :with_country do
      countries { [create(:country)] }
    end
  end
end
