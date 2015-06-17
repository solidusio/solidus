module Spree
  class UserClassHandle
    # Super hack to get around load order.
    def to_s
      Spree.user_class.to_s
    end
  end
end
