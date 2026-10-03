# frozen_string_literal: true

class SolidusAdmin::Products::Form::Identity::Component < SolidusAdmin::BaseComponent
  def initialize(form:)
    @form = form
  end

  def product
    @form.object
  end
end
