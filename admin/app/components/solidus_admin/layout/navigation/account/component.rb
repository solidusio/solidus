# frozen_string_literal: true

class SolidusAdmin::Layout::Navigation::Account::Component < SolidusAdmin::BaseComponent
  def initialize(user_label:, account_path:, logout_path:, logout_method:)
    @user_label = user_label
    @account_path = account_path
    @logout_path = logout_path
    @logout_method = logout_method
  end

  def locale_options_for_select(available_locales)
    available_locales.map do |locale|
      [
        t("spree.i18n.this_file_language", locale: locale, default: locale.to_s, fallback: false),
        locale,
      ]
    end.sort
  end

  def theme_options_for_select
    SolidusAdmin::Config.themes.keys.map { |theme| [theme.to_s.humanize, theme] }.sort
  end

  def autosubmit_select_tag(name, options, icon:, &block)
    form_tag(request.fullpath, method: :get, 'data-turbo': false, class: "w-full") do
      safe_join([
        block_given? ? capture(&block) : nil,
        tag.label(safe_join([
          icon_tag(icon, class: "w-full max-w-[20px] h-5 fill-current shrink"),
          tag.select(options, name: name, onchange: "this.form.requestSubmit()", class: "w-full appearance-none grow bg-transparent outline-none"),
          icon_tag("expand-up-down-line", class: "w-full max-w-[20px] h-5 fill-current shrink"),
        ]), class: "flex gap-2 items-center px-2"),
      ])
    end
  end
end
