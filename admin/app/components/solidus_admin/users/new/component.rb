# frozen_string_literal: true

class SolidusAdmin::Users::New::Component < SolidusAdmin::Resources::New::Component
  private

  def role_options
    Spree::Role.all.map { {label: _1.name, id: _1.id} }
  end
end
