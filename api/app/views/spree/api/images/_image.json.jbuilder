# frozen_string_literal: true

json.call(image, *image_attributes)
json.call(image, :viewable_type, :viewable_id)

Spree::Image.attachment_definitions[:attachment][:styles].each_key do |key|
  json.set! "#{key}_url", image.url(key)
end
