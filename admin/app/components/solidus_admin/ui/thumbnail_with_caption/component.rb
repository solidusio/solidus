# frozen_string_literal: true

class SolidusAdmin::UI::ThumbnailWithCaption::Component < SolidusAdmin::BaseComponent
  attr_reader :icon, :caption, :detail

  def initialize(icon: "question-line", caption: "", detail: nil)
    @icon = icon
    @caption = caption
    @detail = detail
  end

  def icon_thumbnail
    render component("ui/thumbnail").new(icon:)
  end
end
