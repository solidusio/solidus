# frozen_string_literal: true

json.(image, *image_attributes)
json.(image, :viewable_type, :viewable_id)
Spree::Image.attachment_definitions[:attachment][:styles].each_key do |key|
  json.set! "#{key}_url", image.url(key)
end
