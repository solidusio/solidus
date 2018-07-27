# Writing a New Solidus Extension

Sometimes building a site powered by Solidus will require customization.
Solidus extensions are Rails engines that allow you to extend or change the
functionality of the Solidus platform.

## Find existing extensions

Before you write a new Solidus extension you should look for an existing
extension that meets your needs. Solidus maintains an official list of
[supported extension](http://extensions.solidus.io), but you can also use
[soliton](http://soliton.nebulab.it) to search for extensions.

## Developing a Solidus extension locally

### Install the solidus_cmd gem
To develop your own Solidus extension, you'll need to install the
[`solidus_cmd`](https://github.com/solidusio-contrib/solidus_cmd) gem.

```bash
gem install solidus_cmd
```

The `solidus_cmd` gem will generate the boilerplate Rails engine and ensure
that you aren't missing any of the default dependencies.

### Generate a new Solidus extension
Once you've installed `solidus_cmd`, you will have access to the `solidus`
command. Using `solidus extension` will generate a new Solidus extension
template in your current directory.

```bash
solidus extension extension_name
```

### Configure your extension
After `solidus_cmd` has generated your extension template, you will need to
configure your `gemspec` file. This step of the process is similar to [building
any Ruby gem](https://guides.rubygems.org/make-your-own-gem/).

This is the right time to set the version of Solidus you are targeting with
your extension. You can set that dependency and any other dependencies you
anticipate in the `gemspec` file.

### Developing your extension locally
To work on your Solidus extension locally you will need a Solidus application
to host the extension. Setting up a Solidus application specifically for
testing is recommended.

Loading your Solidus extension is as simple as building the gem and adding it
to your `Gemfile`.

Once you're ready to load the extension into your test Solidus application.
You'll need to build your gem with the following command:

```bash
gem build solidus_extension_name.gemspec
```

Then you can add the gem to your Solidus application's `Gemfile` using the
`path` option:

```ruby
gem "solidus_extension_name", path: "path/to/extension"
```

You can now use the `bundle` command to install your extension.
