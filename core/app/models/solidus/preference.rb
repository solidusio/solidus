class Solidus::Preference < Solidus::Base
  serialize :value

  validates :key, presence: true, uniqueness: true
end
