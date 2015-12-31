# Possibly already created by a migration.
unless Solidus::Store.where(code: 'spree').exists?
  Solidus::Store.new do |s|
    s.code              = 'spree'
    s.name              = 'Spree Demo Site'
    s.url               = 'demo.spreecommerce.com'
    s.mail_from_address = 'spree@example.com'
  end.save!
end