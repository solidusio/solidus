# frozen_string_literal: true

module Spree::Variant::HabtmImagesDefinition
  extend ActiveSupport::Concern

  included do
    has_and_belongs_to_many :images_variants, class_name: 'Spree::ImagesVariant'
    has_many :images, through: :images_variants

    after_discard do
      images_variants.destroy_all
    end
  end
end
