# Versioning guidelines

Traditional Spree development involved a lot of overriding behavior through
`class_eval` and overriding views either through [Deface][deface] or by
replacing them. This made upgrading, even through the same `X-Y-stable` branch,
quite dangerous and error-prone.

Our main goal for the Solidus project is to define proper extension points so
that fewer breaking changes are introduced, and those that are introduced are
easily found.

[deface]: https://github.com/spree/deface

## Semantic versioning

As we develop Solidus, we aim to follow [Semantic Versioning][semver] as closely
as we can.

[semver]: http://semver.org

### Patch versions

Patch versions (`x.y.Z`) are reserved for small bug fixes and security patches.
Commits are added sparingly to ensure that stores can always stay on the latest
patch version.

The internal call structure should be maintained so that any overrides to
methods can still be called in the same way. Exceptions may be made for security
fixes if necessary.

### Minor versions

Minor versions (`x.Y.z`) are for any backwards-compatible changes to the public
API.

This is tough to define because our public API could be considered to be all of
the methods on all of our ActiveRecord objects, which is not feasible to
maintain. We use our best judgment about what methods are being used, but there
may still be incompatible changes. Methods we have documented should only have
backwards-compatible changes.

Any `class_eval` overrides or Deface overrides may not be called anymore or be
called in a different way. We use our best judgment to add extension points when
we suspect there would be a store with an override.

We would like to also follow the Rails approach: deprecating functionality in
one minor version and removing it in the next.

### Major versions

Major version (`X.y.z`) are for backwards incompatible changes. We will make an
effort to document breaking changes (and all meaningful changes) in the release
notes.

## End of life policy

We want to offer critical security patches for older versions of Solidus.
However, we cannot offer support for every minor version back to 1.0.

To allow us to patch security issues promptly, and to make sure developers know
how long their Solidus version will receive security updates, we use the
following end of life policy:

**Solidus versions receive security patches for 18 months following their
initial release.**

For example, Solidus 2.4 was released on November, 7, 2017, and will receive
critical patches until May 7, 2019.

This end of life policy affects all minor versions of Solidus following 2.0.
