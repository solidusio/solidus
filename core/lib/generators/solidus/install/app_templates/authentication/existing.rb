user_class = options[:user_class] || "Spree::User"

begin
  user_class.classify.constantize
rescue NameError
  say_status :error, "Can't find an existing user class named #{user_class.classify}, plese set up one before using this authentication option.", :red
  abort
end

generate "spree:custom_user #{user_class.shellescape}"
