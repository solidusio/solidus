module Solidus
  class StateChange < Solidus::Base
    belongs_to :user
    belongs_to :stateful, polymorphic: true
    before_create :assign_user

    def <=>(other)
      created_at <=> other.created_at
    end

    def assign_user
      true   # don't stop the filters
    end
  end
end
