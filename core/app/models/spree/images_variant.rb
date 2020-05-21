# frozen_string_literal: true

module Spree
  class ImagesVariant < Spree::Base
    has_one :image, -> { order(:position) }, as: :viewable, class_name: 'Spree::Image'
    has_and_belongs_to_many :variants, class_name: 'Spree::Variant'
  end
end
