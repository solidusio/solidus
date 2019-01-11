begin
  ActiveDecorator.configure do |config|
    config.decorator_suffix = 'ActiveDecoratorPresenter'
  end
rescue NameError => e

  raise e unless e.missing_name? 'ActiveDecorator'
end
