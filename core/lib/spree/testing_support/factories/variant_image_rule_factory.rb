FactoryGirl.define do
  factory :variant_image_rule, class: Spree::VariantImageRule do
    product

    transient do
      image { create(:image) }
      option_value { create(:option_value) }
    end

    after(:build) do |rule, evaluator|
      rule.conditions.build(option_value: evaluator.option_value)
      rule.values.build(image: evaluator.image)
    end

    after(:create) do |rule, evaluator|
      evaluator.image.update_attributes(viewable: rule.values.first)
    end
  end
end
