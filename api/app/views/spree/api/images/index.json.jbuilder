# frozen_string_literal: true

json.images(@images) do |image|
  json.partial!("spree/api/images/image", image: image)
end
