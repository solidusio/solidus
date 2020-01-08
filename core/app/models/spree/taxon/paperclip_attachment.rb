# frozen_string_literal: true

module Spree::Taxon::PaperclipAttachment
  extend ActiveSupport::Concern

  included do
    has_attached_file :icon,
      styles: { mini: '32x32>', normal: '128x128>' },
      default_style: :mini,
      url: '/spree/taxons/:id/:style/:basename.:extension',
      path: ':rails_root/public/spree/taxons/:id/:style/:basename.:extension',
      default_url: '/assets/default_taxon.png'

    validates_attachment :icon,
      content_type: { content_type: %w[image/jpg image/jpeg image/png image/gif] }
  end

  def icon_present?
    icon.present?
  end

  def attachment_partial_name
    'paperclip'
  end

  def destroy_attachment(definition)
    return false unless respond_to?(definition)

    attached_file = send(definition)
    return false unless attached_file.exists?

    attached_file.destroy
  end
end
