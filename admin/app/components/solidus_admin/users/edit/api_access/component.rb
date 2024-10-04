# frozen_string_literal: true

class SolidusAdmin::Users::Edit::ApiAccess::Component < SolidusAdmin::BaseComponent
  def initialize(user:)
    @user = user
  end
end
