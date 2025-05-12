# frozen_string_literal: true

# ViewComponent v3 provided experimental functionality to define default content for slots
#  https://viewcomponent.org/guide/slots.html#default_slot_name, but unfortunately
#  it did not quite work: https://github.com/ViewComponent/view_component/issues/2169.
# Good news the issue has been resolved, not so good news - it's targeted to be released in v4,
#  so we have to patch the functionality until we upgrade.
# The solution has been copied from here https://github.com/ViewComponent/view_component/pull/2291/files.

require "view_component/version"
if Gem::Version.new(ViewComponent::VERSION::STRING) >= Gem::Version.new("4")
  raise "The fix is included in ViewComponent v4, please remove this patch #{__FILE__}"
end

module SolidusAdmin
  module SlotableDefault
    def get_slot(slot_name)
      @__vc_set_slots ||= {}
      content unless content_evaluated? # ensure content is loaded so slots will be defined

      # If the slot is set, return it
      return @__vc_set_slots[slot_name] if @__vc_set_slots[slot_name]

      # If there is a default method for the slot, call it
      if (default_method = registered_slots[slot_name][:default_method])
        renderable_value = send(default_method)
        slot = ViewComponent::Slot.new(self)

        if renderable_value.respond_to?(:render_in)
          slot.__vc_component_instance = renderable_value
        else
          slot.__vc_content = renderable_value
        end

        slot
      elsif self.class.registered_slots[slot_name][:collection]
        # If empty slot is a collection, return an empty array
        []
      end
    end
  end
end
