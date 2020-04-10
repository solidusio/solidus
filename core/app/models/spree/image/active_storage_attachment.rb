# frozen_string_literal: true

module Spree::Image::ActiveStorageAttachment
  extend ActiveSupport::Concern
  include Spree::ActiveStorageAdapter

  delegate :width, :height, to: :attachment, prefix: true

  included do
    has_attachment :attachment,
                   styles: {
                   mini: '48x48>',
                   small: '400x400>',
                   product: '680x680>',
                   large: '1200x1200>'
                 },
                 default_style: :product
    validates :attachment, presence: true
    validate :attachment_is_an_image
  end
end
