# frozen_string_literal: true

module Solidus
  # Configuration point for User model implementation.
  #
  # `Solidus::UserClassHandle` allows you to configure your own implementation of a
  # User class or use an extension like `solidus_auth_devise`.
  #
  # @note Placeholder for name of Solidus.user_class to ensure later evaluation at
  #  runtime.
  #
  #  Unfortunately, it is possible for classes to get loaded before
  #  Solidus.user_class has been set in the initializer. As a result, they end up
  #  with class_name: "" in their association definitions. For obvious reasons,
  #  that doesn't work.
  #
  #  For now, Rails does not call to_s on the instance passed in until runtime.
  #  So this little hack provides a wrapper around Solidus.user_class so that we
  #  can basically lazy-evaluate it. Yay! Problem solved forever.
  class UserClassHandle
    # @return [String] the name of the user class as a string.
    # @raise [RuntimeError] if Solidus.user_class is nil
    def to_s
      fail "'Solidus.user_class' has not been set yet." unless Solidus.user_class
      "::#{Solidus.user_class}"
    end
  end
end
