# frozen_string_liteal: true

class CreateImagesVariants < ActiveRecord::Migration[6.0]
  def change
    create_table :spree_images_variants do |t|
      t.references :image
    end

    create_table :spree_images_variants_variants do |t|
      t.references :variant
      t.references :images_variant
    end
  end
end
