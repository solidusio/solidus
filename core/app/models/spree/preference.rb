# frozen_string_literal: true

class Solidus::Preference < Solidus::Base
  serialize :value

  validates :key, presence: true, uniqueness: { allow_blank: true }
end
