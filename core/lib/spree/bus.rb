# frozen_string_literal: true

require "omnes"

module Spree
  # Global [Omnes](https://github.com/nebulab/omnes) bus.
  #
  # This is used for internal events, while host applications are also able to
  # use it.
  Bus = Omnes::Bus.new
end
