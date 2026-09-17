# frozen_string_literal: true

# Component wrapper for confirmation dialog. This component uses a modal which
# is rendered in the layout initially hidden. To have it open to confirm a
# user's action, place the "data-turbo-confirm" on the submitter (or any other
# element that supports "data-turbo-confirm" attribute: form, link with
# "data-turbo-method") with the text you want to have in the modal title:
#
#   <form>
#     <button type=submit data-turbo-confirm="Are you sure?">Submit</button>
#   </form>
#
#   <form data-turbo-confirm="Confirm saving">
#   </form>
#
# You can add more details in the body of the modal using "data-confirm-details"
# attribute:
#
#   <button data-turbo-confirm="Are you sure?" data-confirm-details="This cannot be undone.">Submit</button>
#
# To customize "Confirm" button text use "data-confirm-button" attribute:
#
#   <button data-turbo-confirm="This action is not reversible" data-confirm-button="Proceed">Submit</button>
#
class SolidusAdmin::Layout::Confirm::Component < SolidusAdmin::BaseComponent
end
