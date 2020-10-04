# Forking Solidus

If your store requires deep customizations to Solidus' core functionality, you
may want to fork Solidus for your store where you can more freely implement your
features.

Note that this can complicate your Solidus upgrade process or it can break other
Solidus extensions you may wish to use.

The benefit of using a fork of Solidus is that you can test your new features
with Solidus' test suite and ensure that your development did not break any
existing functionality.

You can reference a fork of Solidus in your `Gemfile` this way:

```ruby
gem 'solidus', git: 'https://github.com/my_account/solidus.git', branch: "my-new-feature"
```

If you think your feature or fix is of interest to the wider Solidus
community, [consider making a pull request][contributing].

[contributing]: https://github.com/solidusio/solidus/blob/master/CONTRIBUTING.md

## Create a "private fork"

If your organization needs to work in a private repository for any reason,
forking Solidus becomes slightly more complicated. GitHub does not allow you to
create private forks of public repositories. Instead, you can duplicate the
repository. See GitHub's [Duplicating a repository][duplicating] article for
more information.

[duplicating]: https://help.github.com/articles/duplicating-a-repository/
