# frozen_string_literal: true

module Spree::Store::PaperclipAttachment
  extend ActiveSupport::Concern

  included do
    [:logo, :favicon].each do |name|
      has_attached_file name,
        styles: {},
        default_style: :original,
        url: "/spree/stores/:id/#{name}/:style/:basename.:extension",
        path: ":rails_root/public/spree/stores/:id/#{name}/:style/:basename.:extension"

      validates_attachment name,
        content_type: {content_type: Spree::Config.allowed_image_mime_types}
    end
  end

  def logo_present?
    logo.present?
  end

  def favicon_present?
    favicon.present?
  end

  def destroy_attachment(definition)
    return false unless definition.to_s.in?(%w[logo favicon])

    attached_file = public_send(definition)
    return false unless attached_file.exists?

    attached_file.destroy && save
  end
end
