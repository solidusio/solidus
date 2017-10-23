# we need to require_relative here as there is a lib/spree.rb in the root of solidus.
# If someone is using solidus instead of individual gems, we can't simply require 'spree'
require_relative 'spree'
require 'spree_core'
