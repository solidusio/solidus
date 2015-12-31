Solidus::Sample.load_sample("option_values")
Solidus::Sample.load_sample("products")

ror_baseball_jersey = Solidus::Product.find_by_name!("Ruby on Rails Baseball Jersey")
ror_tote = Solidus::Product.find_by_name!("Ruby on Rails Tote")
ror_bag = Solidus::Product.find_by_name!("Ruby on Rails Bag")
ror_jr_spaghetti = Solidus::Product.find_by_name!("Ruby on Rails Jr. Spaghetti")
ror_mug = Solidus::Product.find_by_name!("Ruby on Rails Mug")
ror_ringer = Solidus::Product.find_by_name!("Ruby on Rails Ringer T-Shirt")
ror_stein = Solidus::Product.find_by_name!("Ruby on Rails Stein")
ruby_baseball_jersey = Solidus::Product.find_by_name!("Ruby Baseball Jersey")
apache_baseball_jersey = Solidus::Product.find_by_name!("Apache Baseball Jersey")

small = Solidus::OptionValue.find_by_name!("Small")
medium = Solidus::OptionValue.find_by_name!("Medium")
large = Solidus::OptionValue.find_by_name!("Large")
extra_large = Solidus::OptionValue.find_by_name!("Extra Large")

red = Solidus::OptionValue.find_by_name!("Red")
blue = Solidus::OptionValue.find_by_name!("Blue")
green = Solidus::OptionValue.find_by_name!("Green")

variants = [
  {
    :product => ror_baseball_jersey,
    :option_values => [small, red],
    :sku => "ROR-00001",
    :cost_price => 17
  },
  {
    :product => ror_baseball_jersey,
    :option_values => [small, blue],
    :sku => "ROR-00002",
    :cost_price => 17
  },
  {
    :product => ror_baseball_jersey,
    :option_values => [small, green],
    :sku => "ROR-00003",
    :cost_price => 17
  },
  {
    :product => ror_baseball_jersey,
    :option_values => [medium, red],
    :sku => "ROR-00004",
    :cost_price => 17
  },
  {
    :product => ror_baseball_jersey,
    :option_values => [medium, blue],
    :sku => "ROR-00005",
    :cost_price => 17
  },
  {
    :product => ror_baseball_jersey,
    :option_values => [medium, green],
    :sku => "ROR-00006",
    :cost_price => 17
  },
  {
    :product => ror_baseball_jersey,
    :option_values => [large, red],
    :sku => "ROR-00007",
    :cost_price => 17
  },
  {
    :product => ror_baseball_jersey,
    :option_values => [large, blue],
    :sku => "ROR-00008",
    :cost_price => 17
  },
  {
    :product => ror_baseball_jersey,
    :option_values => [large, green],
    :sku => "ROR-00009",
    :cost_price => 17
  },
  {
    :product => ror_baseball_jersey,
    :option_values => [extra_large, green],
    :sku => "ROR-00010",
    :cost_price => 17
  },
]

masters = {
  ror_baseball_jersey => {
    :sku => "ROR-001",
    :cost_price => 17,
  },
  ror_tote => {
    :sku => "ROR-00011",
    :cost_price => 17
  },
  ror_bag => {
    :sku => "ROR-00012",
    :cost_price => 21
  },
  ror_jr_spaghetti => {
    :sku => "ROR-00013",
    :cost_price => 17
  },
  ror_mug => {
    :sku => "ROR-00014",
    :cost_price => 11
  },
  ror_ringer => {
    :sku => "ROR-00015",
    :cost_price => 17
  },
  ror_stein => {
    :sku => "ROR-00016",
    :cost_price => 15
  },
  apache_baseball_jersey => {
    :sku => "APC-00001",
    :cost_price => 17
  },
  ruby_baseball_jersey => {
    :sku => "RUB-00001",
    :cost_price => 17
  }
}

Solidus::Variant.create!(variants)

masters.each do |product, variant_attrs|
  product.master.update_attributes!(variant_attrs)
end
