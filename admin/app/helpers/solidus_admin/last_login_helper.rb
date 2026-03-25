# frozen_string_literal: true

module SolidusAdmin
  module LastLoginHelper
    def last_login(user)
      return t("solidus_admin.users.last_login.never") if user.try(:last_sign_in_at).blank?

      t(
        "solidus_admin.users.last_login.login_time_ago",
        # @note The second `.try` is here for the specs and for setups that use a
        # custom User class which may not have this attribute.
        last_login_time: time_ago_in_words(user.try(:last_sign_in_at))
      ).capitalize
    end
  end
end
