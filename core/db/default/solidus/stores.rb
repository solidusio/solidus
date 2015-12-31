# Possibly already created by a migration.
unless Solidus::Store.where(code: 'solidus').exists?
  Solidus::Store.new do |s|
    s.code              = 'solidus'
    s.name              = 'Spree Demo Site'
    s.url               = 'demo.soliduscommerce.com'
    s.mail_from_address = 'solidus@example.com'
  end.save!
end