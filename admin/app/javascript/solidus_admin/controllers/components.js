import "@hotwired/stimulus"

const registeredControllers = {}

// Eager load all controllers registered beneath the `under` path in the import map to the passed application instance.
export function eagerLoadComponents(application, { under, suffix }) {
  const paths = Object.keys(parseImportmapJson()).filter((path) => path.match(new RegExp(`^${under}/.*${suffix}$`)))
  paths.forEach((path) => registerComponent(path, under, application, suffix))
}

function parseImportmapJson() {
  return JSON.parse(document.querySelector("script[type=importmap]").text).imports
}

function registerComponent(path, under, application, suffix) {
  const name = path
    .replace(new RegExp(`^${under}/(.*)${suffix}$`), '$1')
    .replace(/\//g, "--")
    .replace(/_/g, "-")

  if (!(name in registeredControllers)) {
    import(path)
      .then(module => registerController(name, module, application))
      .catch(error => console.error(`Failed to register controller: ${name} (${path})`, error))
  }
}

function registerController(name, module, application) {
  if (!(name in registeredControllers)) {
    application.register(name, module.default)
    registeredControllers[name] = true
  }
};
