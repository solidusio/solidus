# frozen_string_literal: true

FactoryBot.define do
  factory :user_group, class: 'Spree::UserGroup' do
    group_name { "Default User Group" }
  end
end
