# frozen_string_literal: true

# A file field for one of the store's image attachments, with a thumbnail of
# the saved image.
class SolidusAdmin::Stores::Form::Attachment::Component < SolidusAdmin::BaseComponent
  # @param form [ActionView::Helpers::FormBuilder] the store form
  # @param attachment [ActiveStorage::Attached::One] the store's logo or favicon
  def initialize(form:, attachment:)
    @form = form
    @attachment = attachment
  end

  def name
    @attachment.name
  end

  def label
    Spree::Store.human_attribute_name(name)
  end

  # Only a saved attachment has a URL: after a failed save the form is shown
  # again with a new file assigned but not stored yet.
  def preview_url
    store = @attachment.record
    return unless store.persisted? && store.errors.empty?

    @attachment.url if @attachment.attached?
  end
end
