unless Spree::Store.where(code: 'sample-store').exists?
  Spree::Store.create!(
    name: "Sample Store",
    code: "sample-store",
    url: "example.com",
    mail_from_address: "store@example.com"
  )
end
