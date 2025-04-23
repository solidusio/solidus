# frozen_string_literal: true

class SolidusAdmin::Stores::Form::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  def initialize(store:, id:, url:)
    @store = store
    @id = id
    @url = url
  end
end
