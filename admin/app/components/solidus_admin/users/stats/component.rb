# frozen_string_literal: true

class SolidusAdmin::Users::Stats::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::LastLoginHelper

  def initialize(user:)
    @user = user
  end
end
