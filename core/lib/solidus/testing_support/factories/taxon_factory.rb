FactoryGirl.define do
  factory :taxon, class: Solidus::Taxon do
    name 'Ruby on Rails'
    taxonomy
    parent_id nil
  end
end
