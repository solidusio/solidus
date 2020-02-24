# Writing a New Solidus Extension

Sometimes building a site powered by Solidus will require customization.
Solidus extensions are [Rails engines](https://guides.rubyonrails.org/engines.html)
that allow you to extend or change the functionality of the Solidus platform.

## Find existing extensions

Before you write a new Solidus extension you should look for an existing
extension that meets your needs. Solidus maintains an official list of
[supported extensions](http://solidus.io/extensions), but you can also use
[soliton](http://soliton.nebulab.it) to search for extensions in GitHub.

There is also a series of curated extensions available under the
[solidus-contrib](https://github.com/solidusio-contrib) organization.

## Developing a Solidus extension locally

### Install the solidus_dev_support gem
A Solidus extension is just a Rails engine, you can build the extension in
exactly the same way you'd build any other Rails engine.

However, it is recommended that you use the [`solidus_dev_support`](https://github.com/solidusio/solidus_dev_support)
gem.

```bash
gem install solidus_dev_support
```

The `solidus_dev_support` gem will generate the boilerplate Rails engine and
ensure that you aren't missing any of the default dependencies. It also comes
with useful helpers that you may need when working on your extension.

### Generate a new Solidus extension
Once you've installed `solidus_dev_support`, you will have access to the
`solidus` command. Using `solidus extension` will generate a new Solidus
extension template in your current directory.

```bash
solidus extension extension_name
```

### Configure your extension
After `solidus_dev_support` has generated your extension template, you will
need to configure your `gemspec` file. This step of the process is similar
to [building any Ruby gem](https://bundler.io/v1.16/guides/creating_gem.html).

This is the right time to set the version of Solidus you are targeting with
your extension. You can set that dependency and any other dependencies you
anticipate in the `gemspec` file.

### Developing your extension locally
To work on your Solidus extension locally you will need a Solidus application
to host the extension. Setting up a Solidus application specifically for
testing is recommended.

Loading your Solidus extension is as simple as adding it to your `Gemfile`.

Once you're ready to load the extension into your test Solidus application, you
can add the gem to your Solidus application's `Gemfile` using the `path`
option:

```ruby
gem "solidus_extension_name", path: "path/to/extension"
```

You can now use the `bundle` command to install your extension.

### Registering your extension
Solidus extensions benefit from being shared with the community. Sharing your
extension will allow other Solidus developers to extend the functionality of
your code.

You can add your extension to the official list of supported extensions by
submitting a PR to [solidusio/solidus-site](https://github.com/solidusio/solidus-site/blob/master/data/extensions.yml).
