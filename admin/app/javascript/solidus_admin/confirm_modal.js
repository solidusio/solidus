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
  const dialog = document.getElementById("confirm")
  const details = submitter?.dataset.confirmDetails ?? formElement?.dataset.confirmDetails ?? ""
  const buttonText = submitter?.dataset.confirmButton ?? formElement?.dataset.confirmButton
  const accept = dialog.querySelector("#confirm-accept")

  dialog.querySelector(".modal-title").textContent = message
  dialog.querySelector(".modal-body").textContent = details
  if (buttonText) accept.textContent = buttonText

  dialog.showModal()

  return new Promise((resolve) => {
    const controller = new AbortController()
    accept.addEventListener("click", () => { resolve(true); controller.abort(); dialog.close() }, { signal: controller.signal })
    dialog.addEventListener("close", () => { resolve(false); controller.abort() }, { signal: controller.signal })
  })
}
