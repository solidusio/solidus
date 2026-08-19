import { application } from "solidus_admin/controllers/application"

/*
 * Opens a confirmation modal with the given message and options.
 * This is used as the Turbo confirm modal replacement. It returns a
 * Promise that resolves to true if the user confirms, or false if
 * the user cancels.
 *
 * @param {string} message - The message to display in the confirmation modal.
 * @param {HTMLFormElement} formElement - Form element that triggered the
 *   confirmation.
 * @param {HTMLElement} submitter - The element that triggered the form
 *   submission.
 * @returns {Promise<boolean>} - A promise that resolves to true if the user
 *   confirms, or false if the user cancels.
 */
export function openConfirmModal(message, formElement, submitter) {
  const element = document.getElementById("confirm")
  const controller = application.getControllerForElementAndIdentifier(element, "layout--confirm")
  const details = submitter?.dataset.confirmDetails ?? formElement?.dataset.confirmDetails ?? ""
  const buttonText = submitter?.dataset.confirmButton ?? formElement?.dataset.confirmButton

  return controller.open(message, { details, buttonText })
}
