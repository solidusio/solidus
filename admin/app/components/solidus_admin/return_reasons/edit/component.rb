# frozen_string_literal: true

class SolidusAdmin::ReturnReasons::Edit::Component < SolidusAdmin::Resources::Edit::Component
  def initialize(return_reason:)
    @return_reason = return_reason
    super(return_reason)
  end
end
