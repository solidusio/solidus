# frozen_string_literal: true

unless Solidus::Store.where(code: 'sample-store').exists?
  Solidus::Store.create!(
    name: "Sample Store",
    code: "sample-store",
    url: "example.com",
    mail_from_address: "store@example.com"
  )
end
