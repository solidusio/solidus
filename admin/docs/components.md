# Components

Components are the main building blocks of the admin interface. They are implemented as ViewComponents and are rendered directly by controllers.

The following documentation assumes familiarity with ViewComponents. If you are not please refer to the [ViewComponent documentation](https://viewcomponent.org/guide/).

There are two types of components:

- **UI components** are the building blocks of the interface. Typically, they are small components that are used to build more complex components and are generic enough to be reused in various contexts. UI components are located under the `app/components/solidus_admin/ui` folder.
- **Page components** are the primary components rendered by the controllers. Generally, they are full-page components rendered directly by the controllers. They are located under the `app/components/solidus_admin` directory following the naming convention of the controller and action names they are used in. For example `app/components/solidus_admin/orders/index/component.rb` is the component that is rendered by the `SolidusAdmin::OrdersController#index` action.

## Generating components

Components can be generated using the `solidus_admin:component` generator combined with the `bin/rails` command from the Solidus repository.

```shell
$ bin/rails admin g solidus_admin:component foo
      create  app/components/solidus_admin/foo/component.rb
      create  app/components/solidus_admin/foo/component.html.erb
      create  app/components/solidus_admin/foo/component.yml
      create  app/components/solidus_admin/foo/component.js
```

Using `bin/rails admin` will run the generator from the `solidus_admin` engine, instead of the sandbox application.

## Coding style

For UI components in particular, it's preferable to accept only simple Ruby values in the initializer and use alternative constructors to accept more complex objects. This makes components easier to use and test. For example:

```ruby
# bad

class SolidusAdmin::UI::OrderStatus::Component < ViewComponent::Base
  def initialize(order:)
    @order = order
  end
end

# good

class SolidusAdmin::UI::OrderStatus::Component < ViewComponent::Base
  def initialize(status:)
    @status = status
  end

  def self.for_order(order)
    new(status: order.status)
  end
end
```

For style variations within the component we use the term `scheme` rather than `variant` to avoid confusion with product variants.

For size variations we use the term `size` with single letter values, e.g. `s`, `m`, `l`, `xl`, `xxl`.

For text content we use the term `text` rather than `name` to avoid confusion with the `name` attribute of the HTML tag.

## Component registry

Components are registered in the `SolidusAdmin::Config.components` registry. This allows replacing components for customization purposes and components deprecation between versions.

To retrieve component classes from the registry, use the `component` helper within controllers and components that inherit from `SolidusAdmin::BaseComponent` or include `SolidusAdmin::ComponentHelper`. For example, `component('ui/button')` will fetch `SolidusAdmin::UI::Button::Component`.

## When to use UI vs. Page components

Generally new components are built for a specific controller action and are used only within that action. In such cases, it's better to use a Page component and define it under the namespace of the action, e.g. `app/components/solidus_admin/orders/index/payment_status/component.rb`.

If a component is used by multiple actions of the same controller it can be moved to the controller namespace, e.g. `app/components/solidus_admin/orders/payment_status/component.rb`.

When a component is used by multiple controllers, you can either duplicate it in multiple places or move it to the `ui` namespace.

Although it may seem counterintuitive, duplicating the component can often be beneficial. This allows you to modify the component in one place without affecting other components that might be using it. Over time, the two copies may share enough generic code that it can be extracted into a UI component.

UI components should be very generic and reusable. However, they should not try to anticipate all possible use cases. Instead, they should be extracted from existing components that are already used in multiple places. This has proven to be the most effective way to build UI components. We've found that trying to anticipate theoretical use cases often leads to over-engineered code that eventually needs to be adapted to the actual use cases or is never used at all.

## Naming conventions

The project uses a naming convention for components that slightly deviates from ViewComponent defaults. This is done to simplify renaming components and moving them around.

All files related to a component have a base name of `component`, each with its own extension. These files are placed in a folder named after the component class they define.


E.g. `app/components/solidus_admin/orders/index/payment_status/component.rb` defines the `SolidusAdmin::Orders::Index::PaymentStatus::Component` class.

With this approach, renaming a component is as simple as renaming the folder and the class name, without the need to change the names of all the files.

## Translations

Components can define their own translations in the `component.yml` file and they're expected to be self contained. This means that translations defined in `solidus_core` should not be used in components.

Please refer to the [ViewComponent documentation](https://viewcomponent.org/guide/translations.html) for more information.

## Previews and Lookbook

For UI components we leverage [ViewComponent previews](https://viewcomponent.org/guide/previews.html) combined with [Lookbook](https://lookbook.build) to provide a live preview of the component. This approach is highly beneficial for understanding the component's appearance and how it can be modified using different arguments.

Creating previews for page components can be challenging and prone to errors, as they often require a more complex context for rendering. Therefore, we typically don't use previews for page components, except for the most basic ones. However, if a component has a wide range of arguments and we want to cover all combinations, we might create a preview for it.

In order to inspect previews it's enough to visit `/lookbook` in the browser while the server is running.

## Testing

Testing methods for components vary depending on whether they are UI or Page components. UI components are tested in isolation, while Page components, which often require a more complex context, are tested through feature specs.

For UI components, we use previews to achieve maximum coverage. This approach is sufficient for most basic components, but more complex components may require additional specs. This method has proven to minimize maintenance and code churn in the spec code, and it avoids repeating the code needed to render the component with different arguments.

Page components are tested in the context of the controller action they are used in. For example, `admin/spec/features/orders_spec.rb` covers interactions with the order listing and indirectly tests the `SolidusAdmin::Orders::Index::Component` class, among others.
We've found this to be the most effective way to test page components, as recreating the context needed for them in isolation can be difficult and prone to errors.
However, this is not a hard rule. If a Page component needs to be tested in isolation, or if a UI component requires a more complex context, you can always write additional specs.
