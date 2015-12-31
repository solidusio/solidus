FactoryGirl.define do
  factory :tracker, class: Solidus::Tracker do
    analytics_id 'A100'
    active true
  end
end
