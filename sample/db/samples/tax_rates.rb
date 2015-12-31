north_america = Solidus::Zone.find_by_name!("North America")
clothing = Solidus::TaxCategory.find_by_name!("Default")
tax_rate = Solidus::TaxRate.create(
  :name => "North America",
  :zone => north_america, 
  :amount => 0.05,
  :tax_category => clothing)
tax_rate.calculator = Solidus::Calculator::DefaultTax.create!
tax_rate.save!
