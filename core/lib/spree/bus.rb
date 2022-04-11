require 'omnes'

module Spree
  # Global [Omnes](https://github.com/nebulab/omnes) bus.
  #
  # This is used for internal events, while host applications are also able to
  # use it.
  #
  # It has some modifications to support internal usage of the legacy event
  # system {see Spree::AppConfiguration#use_legacy_events}.
  Bus = Omnes::Bus.new
  Bus.define_singleton_method(:publish) do |*args, **kwargs, &block|
    if Spree::Config.use_legacy_events
      Spree::Event.fire(*args, **kwargs, &block)
    else
      super(*args, **kwargs, caller_location: caller_locations(1)[0], &block)
    end
  end
end
