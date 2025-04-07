# StimulusJS

This project uses [StimulusJS](https://stimulusjs.org) to add interactivity to the admin interface.

## Using the `stimulus_id` helper

All JavaScript files are imported using `import-maps`, eliminating the need for compilation.

Any `component.js` file is automatically loaded as a StimulusJS controller. The component path is used as the identifier, which is achieved by using `parameterize` and replacing `/` with `--`.
For example, `app/components/solidus_admin/foo/component.js` is loaded as `solidus-admin--foo`..

To simplify the use of StimulusJS controllers in components, a `stimulus_id` helper is provided.
This helper ensures that the controller identifier is correctly used every time.

```erb
<div
  data-controller="<%= stimulus_id %>"
  data-action="click-><%= stimulus_id %>#doSomething"
  data-<%= stimulus_id %>-foo-value="123"
>
  ...
</div>
```

## Coding Style

Besides the standard StimulusJS conventions, we have a few additional tricks to make the code more readable and maintainable.

### Separating the state from the DOM

Whenever the controller gets beyond trivial we try to separate the state from DOM updates using a `render()` method.

```js
import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "details" ]

  connect() {
    this.render()
  }

  show() {
    this.open = true
  }

  render() {
    this.detailsTarget.hidden = !this.open
  }
}
```

### Using values to communicate with the external world

Values are an excellent tool for communicating with the external environment and representing state.
Any change to them will be reflected in the DOM and the change callbacks provided by StimulusJS are a great way to react to state changes.

```js
import { Controller } from "stimulus"

export default class extends Controller {
  static values = { open: Boolean }

  connect() {
    this.render()
  }

  show() {
    this.openValue = true
  }

  openValueChanged() {
    this.render()
  }

  render() {
    this.detailsTarget.hidden = !this.openValue
  }
}
```

## Leveraging stimulus-use

Solidus Admin leverages [stimulus-use](https://github.com/stimulus-use/stimulus-use/), an external library that offers a collection of composable behaviors for Stimulus Controllers. These mixins greatly simplify the work of developers and can be used when adding new components.
For more information, please refer to the project doc. You can also find examples of usage in the Admin codebase (for instance, `useClickOutside` and `useDebounce` mixins are used in admin components).
