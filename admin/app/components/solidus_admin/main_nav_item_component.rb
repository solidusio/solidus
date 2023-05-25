# frozen_string_literal: true

module SolidusAdmin
  # Menu item within a {MainNavComponent}
  class MainNavItemComponent < BaseComponent
    attr_reader :title

    def initialize(title:)
      @title = title
    end
  end
end
