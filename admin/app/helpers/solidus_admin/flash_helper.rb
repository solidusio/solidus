# frozen_string_literal: true

module SolidusAdmin
  module FlashHelper
    def toasts
      flash.to_hash.with_indifferent_access.except(:alert)
    end
  end
end
