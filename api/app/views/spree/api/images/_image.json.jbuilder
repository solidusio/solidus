# frozen_string_literal: true

json.(image, *image_attributes)
json.(image, :viewable_type, :viewable_id)
Spree::Image.attachment_definitions[:attachment][:styles].each do |k, _v|
  json.set! "#{k}_url", image.attachment.url(k)
end
