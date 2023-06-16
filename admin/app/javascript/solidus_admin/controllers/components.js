import "@hotwired/stimulus"

const registeredControllers = {}

// Eager load all controllers registered beneath the `under` path in the import map to the passed application instance.
export function eagerLoadComponentsFrom(under, application) {
  const paths = Object.keys(parseImportmapJson()).filter(path => path.match(new RegExp(`^${under}/.*/component$`)))
  paths.forEach(path => registerControllerFromPath(path, under, application))
}

function parseImportmapJson() {
  return JSON.parse(document.querySelector("script[type=importmap]").text).imports
}

function registerControllerFromPath(path, under, application) {
  const name = path
    .replace(new RegExp(`^${under}/`), "")
    .replace(/\/component$/, "")
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
