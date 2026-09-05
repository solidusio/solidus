# frozen_string_literal: true

module Spree
  # Configuration point for User model implementations.
  #
  # `Spree::UserClassHandle` and `Spree::AdminUserClassHandle` allow you to
  # configure your own implementation of a User class or use an extension like
  # `solidus_auth_devise`.
  #
  # @note Placeholder for the name of a configured class, to ensure later
  #  evaluation at runtime.
  #
  #  Unfortunately, it is possible for classes to get loaded before
  #  Spree.user_class has been set in the initializer. As a result, they end up
  #  with class_name: "" in their association definitions. For obvious reasons,
  #  that doesn't work.
  #
  #  For now, Rails does not call to_s on the instance passed in until runtime.
  #  So this little hack provides a wrapper around Spree.user_class so that we
  #  can basically lazy-evaluate it. Yay! Problem solved forever.
  class ClassProxy
    # @param setting [String] name of the setting the class name is read from,
    #   used to build the error message when it is unset.
    # @yieldreturn [String, nil] the configured class name, resolved lazily.
    def initialize(setting, &class_name)
      @setting = setting
      @class_name = class_name
    end

    # @return [String] the name of the configured class as a string.
    # @raise [RuntimeError] if the configured class name is nil
    def to_s
      class_name = @class_name.call
      fail "'#{@setting}' has not been set yet." unless class_name
      "::#{class_name}"
    end
  end

  class UserClassHandle < ClassProxy
    def initialize
      super("Spree.user_class") { Spree.user_class_name }
    end
  end

  class AdminUserClassHandle < ClassProxy
    def initialize
      super("Spree.admin_user_class") { Spree.admin_user_class_name }
    end
  end
end
