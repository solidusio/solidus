# frozen_string_literal: true

Spree::Core::Engine.routes.draw do
  resolve("ActiveStorage::Variant")    { |object, options| Rails.application.routes.url_helpers.url_for(object, options.merge(only_path: true)) }
  resolve("ActiveStorage::Preview")    { |object, options| Rails.application.routes.url_helpers.url_for(object, options.merge(only_path: true)) }
  resolve("ActiveStorage::Blob")       { |object, options| Rails.application.routes.url_helpers.url_for(object, options.merge(only_path: true)) }
  resolve("ActiveStorage::Attachment") { |object, options| Rails.application.routes.url_helpers.url_for(object, options.merge(only_path: true)) }
end
