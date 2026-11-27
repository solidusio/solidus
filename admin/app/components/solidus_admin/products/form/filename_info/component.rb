# frozen_string_literal: true

class SolidusAdmin::Products::Form::FilenameInfo::Component < SolidusAdmin::BaseComponent
  include ActionView::Helpers::NumberHelper

  def initialize(
    filename:,
    truncate_at: 10,
    truncate_tail: 3,
    truncate_character: "…",
    truncate_separator: /[\s-]/
  )
    @filename = filename
    @truncate_at = truncate_at
    @truncate_tail = truncate_tail
    @truncate_character = truncate_character
    @truncate_separator = truncate_separator
  end

  def file
    name = File.basename(@filename, ".*")

    return name unless requires_truncation?

    omission = [@truncate_character.presence, name.last(@truncate_tail).presence]
      .compact
      .join

    name.truncate(@truncate_at, separator: @truncate_separator, omission:)
  end

  def extension = File.extname(@filename)&.upcase&.[](1..)

  def requires_truncation? = File.basename(@filename, ".*").length > character_limit

  private

  def character_limit
    [@truncate_at, @truncate_tail].sum
  end

  def character_limits = {beginning: 16, end: 6}
end
