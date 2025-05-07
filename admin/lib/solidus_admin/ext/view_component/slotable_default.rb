# frozen_string_literal: true

# ViewComponent provides experimental functionality to define default content for slots
#  https://viewcomponent.org/guide/slots.html#default_slot_name, but unfortunately
#  it does not quite work: https://github.com/ViewComponent/view_component/issues/2169.
# Here we use a suggested fix from the issue, until it is fixed in ViewComponent.

module ViewComponent
  module SlotableDefault
    def get_slot(slot_name)
      content unless content_evaluated? # ensure content is loaded so slots will be defined

      @__vc_set_slots ||= {}

      return super unless !@__vc_set_slots[slot_name] && (default_method = registered_slots[slot_name][:default_method])

      renderable_value = send(default_method)
      slot = ViewComponent::Slot.new(self)

      if renderable_value.respond_to?(:render_in)
        slot.__vc_component_instance = renderable_value
      else
        slot.__vc_content = renderable_value
      end

      slot
    end
  end
end
