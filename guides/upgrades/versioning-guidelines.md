# Versioning guidelines

As we develop Solidus, we aim to follow [Semantic
Versioning](http://semver.org/) as closely as we can.

Traditional Spree development involved a lot of overriding behaviour through
`class_eval` and overriding views either through [Deface][deface] or by
replacing them.  This made upgrading, even through the same `X-Y-stable` branch,
quite dangerous and error-prone.

Our main goal for the Solidus project is to define proper extension points so
that fewer breaking changes are introduced, and those that are introduced are
easily found.

## Patch versions

Patch versions (`x.y.Z`) are reserved for small bug fixes and security patches.
Commits are added sparingly to ensure that stores can always stay on the latest
patch version.

The internal call structure should be maintained so that any overrides to method
can still be called in the same way. Exceptions may be made for security fixes
if necessary. 

## Minor versions

Minor versions (`x.Y.z`) is for any backwards-compatible changes to the public
API.

This is tough to define because our public API could be considered to be all of
the methods on all of our ActiveRecord objects, which is not feasible to
maintain. We use our best judgment about what methods are being used, but there
may still be incompatible changes. Methods we have documented should only have
backwards-compatible changes.

Any `class_eval` overrides or Deface overrides may not be called any more or be
called in a different way. We use our best judgment to add extension points when
we suspect there would be a store with an override.

We would like to also follow the Rails approach: deprecating functionality in
one minor version and removing it in the next.

## Major versions

Major version (`X.y.z`) are for backwards incompatible changes. We will make an
effort to document breaking changes (and all meaningful changes) in the release
notes.
