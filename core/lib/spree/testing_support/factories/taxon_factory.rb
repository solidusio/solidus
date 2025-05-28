# frozen_string_literal: true

FactoryBot.define do
  factory :taxon, class: "Spree::Taxon" do
    name { "Ruby on Rails" }
    taxonomy_id { (parent&.taxonomy || create(:taxonomy)).id }
    parent_id { parent&.id || taxonomy.root.id }

    trait :with_icon do
      after(:create) do |taxon|
        taxon.update(icon: Spree::Core::Engine.root.join("lib", "spree", "testing_support", "fixtures", "blank.jpg").open)
      end
    end
  end
end
