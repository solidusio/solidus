FactoryGirl.define do
  factory :prototype, class: Solidus::Prototype do
    name 'Baseball Cap'
    properties { [create(:property)] }
  end
end
