# frozen_string_literal: true

Spree::PermissionSets::Base.subclasses.each do |permission|
  Spree::PermissionSet.create!(
    name: permission.name.demodulize,
    set: permission.name,
    privilege: permission.privilege,
    category: permission.category
  )
end
