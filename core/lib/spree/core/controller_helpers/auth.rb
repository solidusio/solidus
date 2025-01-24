# frozen_string_literal: true

Spree.deprecator.warn(
  <<~MSG
    The file "#{__FILE__}" does not need to be `require`d any longer, it is now autoloaded.
  MSG
)
