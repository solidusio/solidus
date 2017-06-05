# Possibly already created by a migration.
unless Spree::Store.where(code: 'spree').exists?
  Spree::Store.new do |s|
    s.code              = 'spree'
    s.name              = 'Sample Store'
    s.url               = 'example.com'
    s.mail_from_address = 'store@example.com'
  end.save!
end
