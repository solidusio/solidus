# Endpoints

<!-- TODO
  This article is a stub.

  Ideally, we can generate documentation for each endpoint and request from
  tests. Maintaining this sort of documentation by hand is a real chore.
-->

The Solidus API documentation is currently a work in progress.

If you want to quickly check for an API endpoint, you can do so locally.

First, ensure you are in your project directory:

```bash
cd my_solidus_application
```

Then, you can filter a `rails routes` command using grep:

```bash
bundle exec rails routes | grep '/api'
```

This command returns a list of every `/api` route that can reach your
application. It includes the type of request (`GET`, `POST`, and so on) that
each route accepts.

You can filter the list of routes being returned with more specific grep input:

```bash
bundle exec rails routes | grep '/api/products'
```
