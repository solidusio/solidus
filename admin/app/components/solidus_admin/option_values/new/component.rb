# frozen_string_literal: true

class SolidusAdmin::OptionValues::New::Component < SolidusAdmin::Resources::New::Component
  def form_url
    solidus_admin.option_type_option_values_path(@option_value.option_type)
  end
end
