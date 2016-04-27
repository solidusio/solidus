# solidus\_sample

Sample contains a set of test data which is used to generate the sandbox can be
used to test out stores.

Applications including the `solidus_sample` gem are provided a rake task to
load the sample data:

```
bundle exec rake spree_sample:load
```


## Testing

Create the test site

    bundle exec rake test_app

Run the tests

    bundle exec rake spec
