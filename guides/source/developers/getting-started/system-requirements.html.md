# System requirements

The following software is required to get Solidus running:

- [Ruby](https://www.ruby-lang.org) 2.2.2 or newer
- [SQLite 3](https://sqlite.org)
- [Rails](http://guides.rubyonrails.org/getting_started.html) 5.0.0 or newer
- [libvips](https://github.com/libvips/libvips) 8.6 or newer, or
  [ImageMagick](http://imagemagick.org/script/download.php)

We recommend using [Homebrew][brew] to install these dependencies on your
Mac. Throughout this article, we will use the `brew` command for installing
system dependencies. [The Ruby documentation also recommends using
Homebrew][ruby-homebrew] if you need to upgrade from your system's Ruby.

We also recommend configuring your development environment so that you can
[install RubyGems without `sudo`][gem-install-without-sudo].

[brew]: https://brew.sh
[ruby-homebrew]: https://www.ruby-lang.org/en/documentation/installation/#homebrew
[gem-install-without-sudo]: https://www.michaelehead.com/2016/02/06/installing-gems-without-sudo.html

## Quick start

Using Homebrew, you can install all of the requirements using the following
commands:

```bash
brew install ruby sqlite3 imagemagick
gem install rails
```

See more detailed installation information below.

## Upgrade Ruby on macOS

If you run macOS Sierra or an older OS, you system's version of Ruby will need
to be upgraded from 2.0.x to 2.2.2 or newer. You can check what version of Ruby
you have installed with the following command:

```bash
ruby --version
```

The Ruby documentation recommends installing another, newer instance of Ruby
using Homebrew:

```bash
brew install ruby
```

Homebrew prioritizes the Homebrew installation of Ruby
(`/usr/local/bin/ruby`) above the system installation (`/usr/bin/ruby`).

## Install SQLite 3

Rails and Solidus use SQLite 3 as the default relational database. SQLite is a
widely-supported, lightweight way to send and receive data. Using Homebrew,
you can install the latest version of SQLite 3 using the following command:

```bash
brew install sqlite3
```

Alternatively, you can [download the pre-compiled binary from the SQLite
website](https://www.sqlite.org/download.html).

After installation, check the version number:

```bash
sqlite3 --version
```

If all is well, this command will return a version number that looks something
like `3.16.0 2016-11-04 19:09:39 0f3eed3324eda2a2b8d3301e5a43dc58a3a5fd5f`.

## Install Rails

Rails includes everything you need to build and extend a web application. Once
you have Ruby and SQLite 3 installed on your system, you can install Rails via
the [RubyGems](https://rubygems.org) `gem` command that comes as a part of Ruby:

```bash
gem install rails
```

This will install Rails as well as its dependencies.

## Install Libvips

If you are upgrading from an older version of Solidus (where Paperclip was used
for product images), and are continuing to use Paperclip for your product images
(see the section on [product images][product-images] for more details), you will
need to install ImageMagick.

If you set up your store with Solidus v3 or newer, you are using ActiveStorage
for your product images by default. As outlined in the [the ActiveStorage
guide][active-storage-guide] you have the choice to install
[libvips](https://github.com/libvips/libvips) (v8.6 or newer) as an alternative
to ImageMagick. Libvips can be [both faster and less memory
intensive](https://github.com/libvips/libvips/wiki/Speed-and-memory-use) than
ImageMagick.

To install libvips via homebrew, use the command:

```bash
brew install libvips
```

[product-images][/developers/products-and-variants/product-images.html]
[active-storage-guide]: https://guides.rubyonrails.org/active_storage_overview.html#requirements

## Install ImageMagick

ImageMagick helps you create, edit, and save to hundreds of image file formats.
It is required by [Paperclip](https://github.com/thoughtbot/paperclip),
which Solidus currently uses to handle file attachments. To install ImageMagick
via Homebrew, use the command:

```bash
brew install imagemagick
```

Alternatively, you can [download a pre-compiled binary for macOS from the
ImageMagick website](http://imagemagick.org/script/download.php).
