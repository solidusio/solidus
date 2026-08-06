import { Turbo } from "@hotwired/turbo-rails"
import "vendor/custom_elements"
import "solidus_admin/controllers"
import { openConfirmModal } from "solidus_admin/confirm_modal"
import "solidus_admin/web_components/solidus_select"

Turbo.config.forms.confirm = openConfirmModal
