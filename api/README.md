# solidus_api

API contains the controllers and Jbuilder views implementing the REST API of
Solidus.

## Testing

Run the API tests:

```bash
bundle exec rspec
```

## Documentation

The API documentation is in the [openapi][docs-dir] directory. It follows the
OpenAPI specification and it is hosted on [Stoplight Docs][live-docs].

If you want to contribute, you can use [Stoplight Studio][studio]. Simply
follow these steps:

1. Create a new Stoplight Studio project
2. Copy-paste the content of `openapi/api.oas2.yml` into your project
3. Edit the endpoints and models as needed
4. Copy-paste the result back into `openapi/api.oas2.yml`
5. Open a PR!

**Note: Only use embedded models in Stoplight Studio, as Stoplight Docs is
not compatible with externally-defined models!**

CircleCI automatically syncs our Git repo with Stoplight Docs when a PR is
merged, and automatically publishes a new version on Docs when a new Solidus
version is released.

## Related projects

- [solidus-sdk](https://gitlab.com/deseretbook/packages/solidus-sdk): created
  by Joel Saupe at [Deseret Book](https://deseretbook.com/), this is a JS SDK
  that allows you to use the Solidus API. It even supports plug-ins, so you can
  easily extend it with the endpoints provided by your Solidus extensions!

[docs-dir]: https://github.com/solidusio/solidus/tree/master/api/openapi
[live-docs]: https://solidus.docs.stoplight.io
[studio]: https://stoplight.io/p/studio
