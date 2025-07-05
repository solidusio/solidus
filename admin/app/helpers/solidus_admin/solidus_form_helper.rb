# frozen_string_literal: true

module SolidusAdmin
  module SolidusFormHelper
    def solidus_form_for(*args, **kwargs, &block)
      form_for(*args, **kwargs, builder: SolidusAdmin::FormBuilder, &block)
    end
  end
end
