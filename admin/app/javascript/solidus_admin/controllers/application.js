import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = location.hostname === "localhost"
window.Stimulus   = application

export { application }
