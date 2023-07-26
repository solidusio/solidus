# frozen_string_literal: true

class SolidusAdmin::UI::Table::Pagination::Component < SolidusAdmin::BaseComponent
  # @param prev_link [String] The link to the previous page.
  # @param next_link [String] The link to the next page.
  def initialize(prev_link: nil, next_link: nil)
    @prev_link = prev_link
    @next_link = next_link
  end

  def render?
    @prev_link.present? || @next_link.present?
  end
end
