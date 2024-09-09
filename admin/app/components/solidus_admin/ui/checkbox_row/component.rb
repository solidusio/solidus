# frozen_string_literal: true

class SolidusAdmin::UI::CheckboxRow::Component < SolidusAdmin::BaseComponent
  def initialize(options:, row_title:, form:, method:, layout: :default)
    @options = options
    @row_title = row_title
    @form = form
    @method = method
    @layout = layout
  end
end
