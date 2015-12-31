Solidus::Gateway::Bogus.create!(
  {
    :name => "Credit Card",
    :description => "Bogus payment gateway",
    :active => true
  }
)

Solidus::PaymentMethod::Check.create!(
  {
    :name => "Check",
    :description => "Pay by check.",
    :active => true
  }
)
