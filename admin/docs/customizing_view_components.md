# Customizing view components

Solidus Admin uses [view components](https://viewcomponent.org/) to render the views. Components are
a pattern for breaking up the view layer into small, reusable pieces, easy to
reason about and test.

All the components Solidus Admin uses are located in the [`app/components`](../app/components) folder of the
`solidus_admin` gem. As you can see, they are organized in a particular folder structure:

- All of them are under the `SolidusAdmin` namespace.
- They are grouped in sidecar directories, where the main component file and
  all its related files (assets, i18n files, etc.) live together.

For instance, the component for the main navigation is located in
[`app/components/solidus_admin/main_nav/component.rb`](../app/components/solidus_admin/main_nav/component.rb).

Solidus Admin components are designed to be easily customizable by the host
application. Because of that, if you look at how they are designed, you'll find
a series of patterns are followed consistently:

- Components are always resolved from a global registry in
  `SolidusAdmin::Container` instead of being referenced by their constant. For
  example, we call `component('main_nav')` instead of referencing
  `SolidusAdmin::MainNav::Component` directly. As you'll see later, this makes
  it easy to replace or tweak a component.
- When a component needs to render another component, it gets it as an argument
  for its `#initialize` method and assigns it to an instance variable ending in
  `_component`. When rendering from the template, it calls the `render` method
  on the instance variable instead of resolving the component in-line. Because
  of that, switching a nested component only requires modifying its
  initializer.
- Those components given on initialization are always defaulted to its expected
  value resolved from the container. That means that callers don't need to
  provide them explicitly, and that they can be replaced by custom components.
- In any case, Solidus Admin components initializers only take keyword
  arguments.

A picture is worth a thousand words, so let's depict how this works with an
example:

```ruby
# app/components/solidus_admin/foo/component.rb
class SolidusAdmin::Foo::Component < SolidusAdmin::BaseComponent
  def initialize(bar_component: component('bar'))
    @bar_component = bar_component
  end
  
  erb_template <<~ERB
    <div>
      <%= render @bar_component.new %>
    </div>
  ERB
end
# render component('foo').new
```

## Customizing components

Some of the customizations detailed below require you to match Solidus Admin's
component paths in your application. For instance, if we talk about the
component in `solidus_admin` gem's
`app/components/solidus_admin/main_nav/component.rb`, the matching path in your
application would be
`app/components/my_application/solidus_admin/main_nav/component.rb`, where
`my_application` is the underscored name of your application (you can get it by
running `Rails.application.class.module_parent_name`).

### Replacing a component's template

> ⓘ This is not possible yet because of
> https://github.com/ViewComponent/view_component/issues/411, but it would
> probably be worth trying to find a way to make it work. Otherwise, we can
> describe how to override the `erb_template` call.

In the most typical case, you'll only need to replace the template used by a
component. You can do that by creating a new template with a maching path in
your application. For example, to replace the main nav template, you can create:

```erb
<%# app/components/my_application/solidus_admin/main_nav/template.html.erb %>
<nav class="my_own_classes">
  <%=
    render main_nav_item_component.with_collection(
      sorted_items
    )
  %>
</nav>
```

### Prepending or appending to a component's template

In some situations, you might only need to add some markup before or after a
component. You can easily do that by rendering the Solidus Admin component and
adding your markup before or after it.

```erb
<%# app/components/my_application/solidus_admin/main_nav/template.html.erb %>
<h1>MY STORE ADMINISTRATION</h1>
<%= render SolidusAdmin::MainNav::Component.new %>
```

### Replacing a component

You can replace a component by creating a new one with a matching path in your
application.

There are two considerations to keep in mind:

- Be aware that other components might be using the component you're replacing.
  They should only be using its `#initialize` method, so make sure to keep
  compatibility with it when they're called.
- Solidus Admin's components always inherit from
  [SolidusAdmin::BaseComponent](../app/components/solidus_admin/base_component.rb).
  You can consider doing the same if you need to use one of its helpers.

For example, the following replaces the main nav component:

```ruby
# app/components/my_application/solidus_admin/main_nav/component.rb
class MyApplication::SolidusAdmin::MainNav::Component < SolidusAdmin::BaseComponent
  # do your thing
end
```

If you need more control, you can explicitly register your component in the
Solidus Admin container instead of using an implicit path:

> ⓘ  Right now, that will raise an error when the application is reloaded. We
> need to fix it.

```ruby
# config/initalizers/solidus_admin.rb
Rails.application.config.to_prepare do
  SolidusAdmin::Container['components.main_nav.component'] = OtherNamespace::NavComponent
end
```

### Tweaking a component

If you only need to tweak a component, you can always inherit from it in a
matching path from within your application (or manually register in the
container) and override the methods you need to change:

```ruby
# app/components/my_application/solidus_admin/main_nav/component.rb
class MyApplication::SolidusAdmin::MainNav::Component < ::SolidusAdmin::MainNav::Component
  def sorted_items
    super.reverse
  end
end
```

Be aware that this approach comes with an important trade-off: You'll need to
keep your component in sync with the original one as it changes on future updates.
For instance, in the example above, the component is overriding a private
method, so there's no guarantee that it will continue to exist in the future
without being deprecated, as we only guarantee public API stability.

### Replacing or tweaking a nested component

If you need to customize a nested component that is used in a single place, you
can do that by following our previous instructions on [replacing a
component](#replacing-a-component) or [tweaking a component](#tweaking-a-component).

However, if the component you want to customize is used in multiple places, you
can replace the default component called from the parent one.

For the sake of example, let's say that the main navigation item component is used in
multiple places, but you only need to change the one rendered from the main
navigation. To begin with, you'd need to manually register in the container the
component you want to use:

```ruby
Rails.application.config.to_prepare do
  SolidusAdmin::Container.register('components.main_nav_item_foo.component', MyApplication::SolidusAdmin::MainNavItemFoo::Component)
end
```

Then, you can change the default value of the `main_nav_item_component`
argument from the top-level nav component:

```ruby
# app/components/my_application/solidus_admin/main_nav/component.rb
class MyApplication::SolidusAdmin::MainNav::Component < ::SolidusAdmin::MainNav::Component
  def initialize(main_nav_item_component: component('main_nav_item_foo'), **kwargs)
    super
  end
end
```
