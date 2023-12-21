# frozen_string_literal: true

class SolidusAdmin::Layout::SkipLink::Component < SolidusAdmin::BaseComponent
  def initialize(href:)
    @href = href
  end

  def call
    link_to t(".skip_link"),
            @href,
            class: %{
              sr-only
              focus:not-sr-only
              inline-block
              focus:p-2
              focus:absolute
              font-normal text-sm
              text-white
              bg-black
            }
  end
end
