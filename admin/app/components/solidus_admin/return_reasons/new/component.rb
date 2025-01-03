# frozen_string_literal: true

class SolidusAdmin::ReturnReasons::New::Component < SolidusAdmin::Resources::New::Component
  def initialize(return_reason:)
    @return_reason = return_reason
    super(return_reason)
  end
end
