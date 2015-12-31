module Solidus
  class OptionTypePrototype < Solidus::Base
    belongs_to :option_type
    belongs_to :prototype
  end
end
