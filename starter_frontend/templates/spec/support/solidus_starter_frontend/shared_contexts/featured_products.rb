# frozen_string_literal: true

RSpec.shared_context "featured products" do
  before(:each) do
    create(:store)
    categories = create(:taxonomy, name: 'Categories')
    categories_root = categories.root
    clothing_taxon = create(:taxon, name: 'Clothing', parent_id: categories_root.id, taxonomy: categories)
    image = create(:image)
    variant = create(:variant, images: [image, image])

    create(:custom_product, name: 'Solidus hoodie', price: '29.99', taxons: [clothing_taxon], variants: [variant])
  end
end
