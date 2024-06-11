// Import and register all your controllers from the importmap under controllers/*

import { application } from "solidus_admin/controllers/application"

// Eager load all controllers defined in the import map under controllers/**/*_controller
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("solidus_admin/controllers", application)

// Lazy load controllers as they appear in the DOM (remember not to preload controllers in import map!)
// import { lazyLoadControllersFrom } from "@hotwired/stimulus-loading"
// lazyLoadControllersFrom("controllers", application)

import { eagerLoadComponents } from "solidus_admin/controllers/components"
eagerLoadComponents(application, { under: "solidus_admin", suffix: "/component" })
