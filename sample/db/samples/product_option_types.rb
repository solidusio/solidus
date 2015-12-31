Solidus::Sample.load_sample("products")

size = Solidus::OptionType.find_by_presentation!("Size")
color = Solidus::OptionType.find_by_presentation!("Color")

ror_baseball_jersey = Solidus::Product.find_by_name!("Ruby on Rails Baseball Jersey")
ror_baseball_jersey.option_types = [size, color]
ror_baseball_jersey.save!

