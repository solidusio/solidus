FactoryBot.define do
  factory :option_value, class: Spree::OptionValue do
    sequence(:name) { |n| "Size-#{n}" }

    presentation { 'S' }
    option_type
  end
end
