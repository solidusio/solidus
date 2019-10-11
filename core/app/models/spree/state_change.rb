# frozen_string_literal: true

module Solidus
  class StateChange < Solidus::Base
    belongs_to :user, optional: true
    belongs_to :stateful, polymorphic: true, optional: true
    before_create :assign_user

    def <=>(other)
      created_at <=> other.created_at
    end

    def assign_user
      true # don't stop the filters
    end
  end
end
