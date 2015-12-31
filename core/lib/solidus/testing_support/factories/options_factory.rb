FactoryGirl.define do
  factory :option_value, class: Solidus::OptionValue do
    sequence(:name) { |n| "Size-#{n}" }

    presentation 'S'
    option_type
  end

  factory :option_type, class: Solidus::OptionType do
    sequence(:name) { |n| "foo-size-#{n}" }
    presentation 'Size'
  end
end
