Spree::Sample.load_sample("products")
Spree::Sample.load_sample("variants")

products = {}
products[:ror_baseball_jersey] = Spree::Product.find_by_name!("Ruby on Rails Baseball Jersey")
products[:ror_tote] = Spree::Product.find_by_name!("Ruby on Rails Tote")
products[:ror_bag] = Spree::Product.find_by_name!("Ruby on Rails Bag")
products[:ror_jr_spaghetti] = Spree::Product.find_by_name!("Ruby on Rails Jr. Spaghetti")
products[:ror_mug] = Spree::Product.find_by_name!("Ruby on Rails Mug")
products[:ror_ringer] = Spree::Product.find_by_name!("Ruby on Rails Ringer T-Shirt")
products[:ror_stein] = Spree::Product.find_by_name!("Ruby on Rails Stein")
products[:ruby_baseball_jersey] = Spree::Product.find_by_name!("Ruby Baseball Jersey")
products[:apache_baseball_jersey] = Spree::Product.find_by_name!("Apache Baseball Jersey")

def image(name, type = "jpeg")
  images_path = Pathname.new(File.dirname(__FILE__)) + "images"
  path = images_path + "#{name}.#{type}"
  return false if !File.exist?(path)
  path
end

images = {
  products[:ror_tote].master => [
    {
      attachment: image("ror_tote")
    },
    {
      attachment: image("ror_tote_back")
    }
  ],
  products[:ror_bag].master => [
    {
      attachment: image("ror_bag")
    }
  ],
  products[:ror_baseball_jersey].master => [
    {
      attachment: image("ror_baseball")
    },
    {
      attachment: image("ror_baseball_back")
    }
  ],
  products[:ror_jr_spaghetti].master => [
    {
      attachment: image("ror_jr_spaghetti")
    }
  ],
  products[:ror_mug].master => [
    {
      attachment: image("ror_mug")
    },
    {
      attachment: image("ror_mug_back")
    }
  ],
  products[:ror_ringer].master => [
    {
      attachment: image("ror_ringer")
    },
    {
      attachment: image("ror_ringer_back")
    }
  ],
  products[:ror_stein].master => [
    {
      attachment: image("ror_stein")
    },
    {
      attachment: image("ror_stein_back")
    }
  ],
  products[:apache_baseball_jersey].master => [
    {
      attachment: image("apache_baseball", "png")
    }
  ],
  products[:ruby_baseball_jersey].master => [
    {
      attachment: image("ruby_baseball", "png")
    }
  ]
}

products[:ror_baseball_jersey].variants.each do |variant|
  color = variant.option_value("tshirt-color").downcase
  main_image = image("ror_baseball_jersey_#{color}", "png")
  File.open(main_image) do |f|
    variant.images.create!(attachment: f)
  end
  back_image = image("ror_baseball_jersey_back_#{color}", "png")
  next unless back_image
  File.open(back_image) do |f|
    variant.images.create!(attachment: f)
  end
end

images.each do |variant, attachments|
  puts "Loading images for #{variant.product.name}"
  attachments.each do |attachment|
    File.open(attachment[:attachment]) do |f|
      variant.images.create!(attachment: f)
    end
  end
end
