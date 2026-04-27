# Solidus Starter Frontend development information
This document aims to give some extra information for developers that are going
to contribute to our `solidus_starter_frontend` component.

### Running the sandbox

You can run `bin/dev` to create a sandboxed Solidus application, start the server and the watcher process that will update files in the sandbox whenever something
changes in the templates folder.

```
$ bin/dev
18:54:04 web.1   | started with pid 39831
18:54:04 watch.1 | started with pid 39832
18:54:04 watch.1 | 18:54:04 - INFO - Guard is now watching at '/Users/elia/Code/Nebulab/solidus_starter_frontend'
18:54:05 web.1   | => Booting Puma
18:54:05 web.1   | => Rails 7.0.4.1 application starting in development
18:54:05 web.1   | => Run `bin/rails server --help` for more startup options
18:54:06 web.1   | Puma starting in single mode...
18:54:06 web.1   | * Puma version: 5.6.5 (ruby 2.7.6-p219) ("Birdie's Version")
18:54:06 web.1   | *  Min threads: 5
18:54:06 web.1   | *  Max threads: 5
18:54:06 web.1   | *  Environment: development
18:54:06 web.1   | *          PID: 39833
18:54:06 web.1   | * Listening on http://127.0.0.1:3000
18:54:06 web.1   | * Listening on http://[::1]:3000
18:54:06 web.1   | Use Ctrl-C to stop
```

If you need to recreate the sandbox from scratch you can run `bin/sandbox`.

Using `bin/rails` will forward any Rails commands to `sandbox/bin/rails`.

Default username and password for admin are: `admin@example.com` and `test123`.

To run the watcher manually please use `bin/guard` (see the Guardfile for the
configuration).

### Docker development

If you are a docker user you can wake up the project as usual with:

```bash
docker-compose up -d
```

Wait for all the dependencies to be installed. You can check progress with `docker-compose logs -f app`.

Then you can dispatch commands to the `app` container:

```bash
docker-compose exec app bin/rails server
```

When running the [sandbox application](#running-the-sandbox), take into account
that you need to bind to `0.0.0.0`. By default, port `3000` is exposed but you
can changed it through `SANDBOX_PORT` environment variable:

```bash
SANDBOX_PORT=4000 docker-compose up -d
docker-compose exec app bin/sandbox
docker-compose exec app bin/rails server --binding 0.0.0.0 --port 4000
```
