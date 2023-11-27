# frozen_string_literal: true

class SolidusAdmin::Taxes::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers
  renders_one :actions
end
