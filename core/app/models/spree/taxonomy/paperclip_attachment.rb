# frozen_string_literal: true

module Spree::Taxonomy::PaperclipAttachment
  extend ActiveSupport::Concern

  included do
    has_attached_file :icon,
      styles: Spree::Config.taxon_image_styles,
      default_style: Spree::Config.taxon_image_style_default,
      url: '/spree/taxonomies/:id/:style/:basename.:extension',
      path: ':rails_root/public/spree/taxonomies/:id/:style/:basename.:extension',
      default_url: '/assets/default_taxon.png'

    validates_attachment :icon,
      content_type: { content_type: Spree::Config.allowed_image_mime_types }
  end

  def icon_present?
    icon.present?
  end

  def destroy_attachment(definition)
    return false unless respond_to?(definition)

    attached_file = send(definition)
    return false unless attached_file.exists?

    attached_file.destroy && save
  end
end
