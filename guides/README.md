# Solidus Guides

If you want to contribute to the Solidus documentation be sure to read the
[dedicated section](https://github.com/solidusio/solidus/blob/master/guides/source/contributing.html.md) first.

The documentation files can be found
[inside the `source/` folder](https://github.com/solidusio/solidus/tree/master/guides/source).

---

The Solidus documentation is published with [Middleman](https://middlemanapp.com),
and based on [https://github.com/joshukraine/middleman-gulp](https://github.com/joshukraine/middleman-gulp).

Requirements
------------

* Middleman 4.x
* Ruby 2.x
* Yarn

Usage
-----

1. Install ruby gems `bundle install`

2. Install JavaScript packages `yarn install`

3. Start the Middleman server. Note that this will also invoke Webpack via the external pipeline.

```bash
$ bundle exec middleman server
```

4. To build HTML and assets for production, run:

```bash
$ bundle exec middleman build
```

5. Set proper `base_url` in config.rb
