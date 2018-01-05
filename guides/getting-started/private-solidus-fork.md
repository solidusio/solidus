# Private Solidus fork

If your store requires deep customizations to Solidus's core functionality, you
may want to fork Solidus for your store where you can more freely implement your
features.

Note that this can complicate your Solidus upgrade process or can break other
Solidus extensions you may wish to use.

The benefit of a private fork is that you can test your new features with
Solidus's test suite and ensure your development has not broken Solidus's
existing functionality.

You can reference a private fork of Solidus in your `Gemfile` this way:

```ruby
gem 'solidus', git: 'https://github.com/my_account/solidus.git', branch: "my-new-feature"
```

If you think your feature (or fix) if of interest to the wider Solidus
community, [consider making a pull request][contributing].

[contributing]: https://github.com/solidusio/solidus/blob/master/CONTRIBUTING.md
