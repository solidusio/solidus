# frozen_string_literal: true

module Spree::Variant::HmImagesDefinition
  extend ActiveSupport::Concern

  included do
    has_many :images, -> { order(:position) }, as: :viewable, dependent: :destroy, class_name: "Spree::Image"

    after_discard do
      images.destroy_all
    end
  end
end
