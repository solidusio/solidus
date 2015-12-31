FactoryGirl.define do
  factory :store, class: Solidus::Store do
    sequence(:code) { |i| "solidus_#{i}" }
    sequence(:name) { |i| "Spree Test Store #{i}" }
    sequence(:url) { |i| "www.example#{i}.com" }
    mail_from_address 'solidus@example.org'
  end
end
