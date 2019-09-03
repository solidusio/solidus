# solidus\_api

API contains the controllers and rabl views implementing the REST API of Solidus.

## Testing

Run the API tests:

```bash
bundle exec rspec
```

## Documentation

The API documentation is in the [openapi](https://github.com/solidusio/solidus/tree/master/api/openapi)
directory. It follows the OpenAPI specification and it is hosted on
[Stoplight](https://solidus.docs.stoplight.io/).

If you want to contribute, you can use [Stoplight Studio](https://stoplight.io/p/studio),
an OpenAPI editor, to edit the files visually, and copy-paste the 
resulting code into the `openapi` directory.

CircleCI automatically syncs our Git repo with Stoplight when a PR is
merged, and automatically publishes a new version on Stoplight when
a new Solidus version is released.
