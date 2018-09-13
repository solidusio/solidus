# How to release new versions

## Release a new MINOR version

Let's say latest version on master is 2.7.0.alpha and we want to release a new
2.7 versions.

These are the steps required for the release to happen:

### Make sure CHANGELOG.md is up to date

Our CHANGELOG is where all the major changes are listed. It's a great
resource for developers that want to update their store since they can
walk through it and understand if there are changes that can impact their
stores. Take a look at the current [CHANGELOG](https://github.com/solidusio/solidus/blob/master/CHANGELOG.md) to
better understand how to update it.

### Prepare the repository

Open `core/lib/spree/core/version.rb` file and change from

```ruby
def self.solidus_version
  "2.7.0.alpha"
end
```

to

```ruby
def self.solidus_version
  "2.7.0"
end
```

Do create a PR on master. When it's merged you can create a new
version branch (`v2.7`) that will help us understand what's inside each
version in the future and relase new PATCH level versions.

```sh
git fetch -a upstream
git checkout -b v2.7 upstream/master
git push -u upstream v2.7
```

### Publish the new version on Rubygems

Now it's time to build and push gems to rubygems. Be sure you have right
rubygems permissions, take a look at [their guides](https://guides.rubygems.org/publishing/).

We need to release all gems that compose `solidus` individually before pushing
it, let's do every step with these commands:

```sh
cd core && gem build solidus_core && gem push solidus_core-2.7.0.gem && cd ..
cd api && gem build solidus_api && gem push solidus_api-2.7.0.gem && cd ..
cd frontend && gem build solidus_frontend && gem push solidus_frontend-2.7.0.gem && cd ..
cd backend && gem build solidus_backend && gem push solidus_backend-2.7.0.gem && cd ..
cd sample && gem build solidus_sample && gem push solidus_sample-2.7.0.gem && cd ..
gem build solidus.gemspec && gem push solidus-2.7.0.gem
```

Let's cleanup our folders:

```
rm backend/solidus_backend-2.7.0.gem core/solidus_core-2.7.0.gem frontend/solidus_frontend-2.7.0.gem sample/solidus_sample-2.7.0.gem solidus-2.7.0.gem
```

### Create a GH release

Now you can go on GH and create a release into:

https://github.com/solidusio/solidus/releases


### Prepare master for the next version:

In the master branch let's start a 2.8.0.alpha


Open `core/lib/spree/core/version.rb` file and change from:

```ruby
def self.solidus_version
  "2.7.0"
end
```

to:

```ruby
def self.solidus_version
  "2.8.0.alpha"
end
```

## Release a new PATCH version

Suppose latest 2.6.x is 2.6.0 and we want to release a new 2.6.1 version.

First thing to do is checking out to the right branch:

```
git checkout v2.6
```

Open `core/lib/spree/core/version.rb` file and change from

```ruby
def self.solidus_version
  "2.6.0"
end
```

to

```ruby
def self.solidus_version
  "2.6.1"
end
```

### Publish the new version on Rubygems

Now it's time to build and push gems to rubygems. Be sure you have right
rubygems permissions, take a look at [their guides](https://guides.rubygems.org/publishing/).

We need to release all gems that compose `solidus` individually before pushing
it, let's do every step with these commands:

```sh
cd core && gem build solidus_core && gem push solidus_core-2.6.1.gem && cd ..
cd api && gem build solidus_api && gem push solidus_api-2.6.1.gem && cd ..
cd frontend && gem build solidus_frontend && gem push solidus_frontend-2.6.1.gem && cd ..
cd backend && gem build solidus_backend && gem push solidus_backend-2.6.1.gem && cd ..
cd sample && gem build solidus_sample && gem push solidus_sample-2.6.1.gem && cd ..
gem build solidus.gemspec && gem push solidus-2.6.1.gem
```

Let's cleanup our folders:

```
rm backend/solidus_backend-2.6.1.gem core/solidus_core-2.6.1.gem frontend/solidus_frontend-2.6.1.gem sample/solidus_sample-2.6.1.gem solidus-2.6.1.gem
```

### Create a GH release

Now you can go on GH and create a release into:

https://github.com/solidusio/solidus/releases
