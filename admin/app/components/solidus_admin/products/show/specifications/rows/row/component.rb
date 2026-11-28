# frozen_string_literal: true

class SolidusAdmin::Products::Show::Specifications::Rows::Row::Component < SolidusAdmin::BaseComponent
  # @param form [SolidusAdmin::FormBuilder] the nested form builder for one
  #   property value, as yielded by +fields_for+
  def initialize(form:)
    @form = form
  end
end
