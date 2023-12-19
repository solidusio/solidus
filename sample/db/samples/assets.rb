# frozen_string_literal: true

require 'thor'
shell = Thor::Base.shell.new

Spree::Sample.load_sample("products")
Spree::Sample.load_sample("variants")

products = {}
products[:solidus_bottles] = Spree::Product.includes(variants: [:option_values]).find_by!(name: "Solidus Water Bottle")
products[:solidus_tote] = Spree::Product.includes(variants: [:option_values]).find_by!(name: "Solidus tote")
products[:solidus_hoodie] = Spree::Product.includes(variants: [:option_values]).find_by!(name: "Solidus hoodie")
products[:solidus_hat] = Spree::Product.includes(variants: [:option_values]).find_by!(name: "Solidus winter hat")
products[:solidus_sticker] = Spree::Product.includes(variants: [:option_values]).find_by!(name: "Solidus circle sticker")
products[:solidus_cap] = Spree::Product.includes(variants: [:option_values]).find_by!(name: "Solidus cap")

products[:solidus_mug_set] = Spree::Product.find_by!(name: "Solidus mug set")
products[:solidus_notebook] = Spree::Product.find_by!(name: "Solidus notebook")
products[:solidus_tshirt] = Spree::Product.find_by!(name: "Solidus t-shirt")
products[:solidus_long_sleeve_tee] = Spree::Product.find_by!(name: "Solidus long sleeve tee")
products[:solidus_dark_tee] = Spree::Product.find_by!(name: "Solidus dark tee")
products[:solidus_canvas_tote] = Spree::Product.find_by!(name: "Solidus canvas tote bag")
products[:solidus_cap] = Spree::Product.find_by!(name: "Solidus cap")

def image(name, type = "png")
  images_path = Pathname.new(File.dirname(__FILE__)) + "images"
  path = images_path + "#{name}.#{type}"

  return false if !File.exist?(path)

  path
end

images = {
  products[:solidus_bottles].master => [
    {
      attachment: image("solidus_bottles")
    }
  ],
  products[:solidus_tote].master => [
    {
      attachment: image("solidus_tote")
    }
  ],
  products[:solidus_hoodie].master => [
    {
      attachment: image("solidus_hoodie")
    }
  ],
  products[:solidus_hat].master => [
    {
      attachment: image("solidus_hat")
    }
  ],
  products[:solidus_sticker].master => [
    {
      attachment: image("solidus_sticker")
    }
  ],
  products[:solidus_mug_set].master => [
    {
      attachment: image("solidus_mug_set")
    }
  ],
  products[:solidus_notebook].master => [
    {
      attachment: image("solidus_notebook")
    }
  ],
  products[:solidus_tshirt].master => [
    {
      attachment: image("solidus_tshirt")
    }
  ],
  products[:solidus_long_sleeve_tee].master => [
    {
      attachment: image("solidus_long_sleeve_tee")
    }
  ],
  products[:solidus_dark_tee].master => [
    {
      attachment: image("solidus_dark_tee")
    }
  ],
  products[:solidus_canvas_tote].master => [
    {
      attachment: image("solidus_canvas_tote")
    }
  ],
  products[:solidus_cap].master => [
    {
      attachment: image("solidus_cap")
    }
  ],
}

products.each do |key, product|
  product.reload.variants.each do |variant|
    color = variant.option_value("clothing-color").downcase
    index = 1

    loop do
      image_path = image("#{key}_#{color}_#{index}", 'png')
      break unless image_path

      File.open(image_path) do |f|
        variant.images.create!(attachment: f)
      end

      index += 1
    end
  end
end

images.each do |variant, attachments|
  shell.say_status :sample, "images for #{variant.product.name}"
  attachments.each do |attachment|
    File.open(attachment[:attachment]) do |f|
      variant.images.create!(attachment: f)
    end
  end
end
