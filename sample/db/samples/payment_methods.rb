Spree::Gateway::Bogus.create!(
  {
    :name => "Credit Card",
    :description => "Bogus payment gateway for development.",
    :active => true
  }
)

Spree::Gateway::Bogus.create!(
  {
    :name => "Credit Card",
    :description => "Bogus payment gateway for production.",
    :active => true
  }
)

Spree::Gateway::Bogus.create!(
  {
    :name => "Credit Card",
    :description => "Bogus payment gateway for staging.",
    :active => true
  }
)

Spree::Gateway::Bogus.create!(
  {
    :name => "Credit Card",
    :description => "Bogus payment gateway for test.",
    :active => true
  }
)

Spree::PaymentMethod::Check.create!(
  {
    :name => "Check",
    :description => "Pay by check.",
    :active => true
  }
)
