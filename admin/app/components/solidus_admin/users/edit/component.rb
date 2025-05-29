# frozen_string_literal: true

class SolidusAdmin::Users::Edit::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  def initialize(user:)
    @user = user
  end

  def form_id
    @form_id ||= "#{stimulus_id}--form-#{@user.id}"
  end

  def role_options
    Spree::Role.all.map do |role|
      { label: role.name, id: role.id }
    end
  end
end
