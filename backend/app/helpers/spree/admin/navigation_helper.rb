# frozen_string_literal: true

module Spree
  module Admin
    module NavigationHelper
      def admin_breadcrumbs
        @admin_breadcrumbs ||= []
      end

      # Add items to current page breadcrumb hierarchy
      def admin_breadcrumb(*ancestors, &block)
        admin_breadcrumbs.concat(ancestors) if ancestors.present?
        admin_breadcrumbs.push(capture(&block)) if block_given?
      end

      # Render Bootstrap style breadcrumbs
      def render_admin_breadcrumbs
        if content_for?(:page_title)
          admin_breadcrumb(content_for(:page_title))
        end

        content_tag :ol, class: "breadcrumb" do
          segments = admin_breadcrumbs.map do |level|
            content_tag(:li, level, class: "breadcrumb-item #{(level == admin_breadcrumbs.last) ? "active" : ""}")
          end
          safe_join(segments)
        end
      end

      def admin_page_title
        if content_for?(:title)
          content_for(:title)
        elsif content_for?(:page_title)
          content_for(:page_title)
        elsif admin_breadcrumbs.any?
          admin_breadcrumbs.map { |breadcrumb| strip_tags(breadcrumb) }.reverse.join(" - ")
        else
          t(controller.controller_name, default: controller.controller_name.titleize, scope: "spree")
        end
      end

      # Make an admin tab that covers one or more resources supplied by symbols
      # Option hash may follow. Valid options are
      #   * :label to override link text, otherwise based on the first resource name (translated)
      #   * :match_path as an alternative way to control when the tab is active, /products would match /admin/products, /admin/products/5/variants etc.
      #   * :match_path can also be a callable that takes a request and determines whether the menu item is selected for the request.
      #   * :selected to explicitly control whether the tab is active
      def tab(*args, &block)
        options = args.last.is_a?(Hash) ? args.pop.dup : {}
        css_classes = Array(options[:css_class])

        if options.key?(:route)
          Spree.deprecator.warn "Passing a route to #tab is deprecated. Please pass a url instead."
          options[:url] ||= spree.send(:"#{options[:route]}_path")
        end

        if args.any?
          Spree.deprecator.warn "Passing resources to #tab is deprecated. Please use the `label:` and `match_path:` options instead."
          options[:label] ||= args.first
          options[:url] ||= spree.send(:"admin_#{args.first}_path")
          options[:selected] = args.include?(controller.controller_name.to_sym)
        end

        options[:url] ||= spree.send(:"admin_#{options[:label]}_path")
        label = t(options[:label], scope: [:spree, :admin, :tab])

        options[:selected] ||=
          if options[:match_path].is_a? Regexp
            request.fullpath =~ options[:match_path]
          elsif options[:match_path].respond_to?(:call)
            options[:match_path].call(request)
          elsif options[:match_path]
            request.fullpath.starts_with?("#{spree.admin_path}#{options[:match_path]}")
          else
            request.fullpath.starts_with?(options[:url])
          end

        css_classes << "selected" if options[:selected]

        if options[:icon]
          link = link_to_with_icon(options[:icon], label, options[:url])
          css_classes << "tab-with-icon"
        else
          link = link_to(label, options[:url])
        end
        block_content = capture(&block) if block_given?
        content_tag("li", link + block_content.to_s, class: css_classes.join(" "))
      end

      def link_to_clone(resource, options = {})
        options[:data] = {action: "clone"}
        options[:method] = :post
        link_to_with_icon("copy", t("spree.clone"), clone_object_url(resource), options)
      end

      def link_to_new(resource)
        options[:data] = {action: "new"}
        link_to_with_icon("plus", t("spree.new"), edit_object_url(resource))
      end

      def link_to_edit(resource, options = {})
        url = options[:url] || edit_object_url(resource)
        options[:data] = {action: "edit"}
        link_to_with_icon("edit", t("spree.actions.edit"), url, options)
      end

      def link_to_edit_url(url, options = {})
        options[:data] = {action: "edit"}
        link_to_with_icon("edit", t("spree.actions.edit"), url, options)
      end

      def link_to_delete(resource, options = {})
        url = options[:url] || object_url(resource)
        name = options[:name] || t("spree.actions.delete")
        confirm = options[:confirm] || t("spree.are_you_sure")
        options[:class] = "#{options[:class]} delete-resource".strip
        options[:data] = {confirm:, action: "remove"}
        link_to_with_icon "trash", name, url, options
      end

      def link_to_with_icon(icon_name, text, url, options = {})
        options[:class] = "#{options[:class]} icon_link with-tip".strip

        if icon_name.starts_with?("ri-")
          svg_map = image_path("spree/backend/themes/solidus_admin/remixicon.symbol.svg")
          icon_tag = tag.svg(
            tag.use("xlink:href": "#{svg_map}##{icon_name}"),
            "aria-hidden": true,
            style: "fill: currentColor;"
          )
        else
          options[:class] << " fa fa-#{icon_name}"
          icon_tag = "".html_safe
        end

        options[:class] += " no-text" if options[:no_text]
        options[:title] = text if options[:no_text]
        text = options[:no_text] ? "" : content_tag(:span, text, class: "text")
        options.delete(:no_text)
        link_to(icon_tag + text, url, options)
      end

      def solidus_icon(icon_name)
        icon_name ? content_tag(:i, "", class: icon_name) : ""
      end

      def configurations_menu_item(link_text, url, description = "")
        %(<tr>
          <td>#{link_to(link_text, url)}</td>
          <td>#{description}</td>
        </tr>
        ).html_safe
      end

      def configurations_sidebar_menu_item(link_text, url, options = {})
        is_active = url.ends_with?(controller.controller_name) ||
          url.ends_with?("#{controller.controller_name}/edit") ||
          url.ends_with?("#{controller.controller_name.singularize}/edit")
        options[:class] = is_active ? "active" : nil
        content_tag(:li, options) do
          link_to(link_text, url)
        end
      end

      def settings_tab_item(link_text, url, options = {})
        is_active = url.ends_with?(controller.controller_name) ||
          url.ends_with?("#{controller.controller_name}/edit") ||
          url.ends_with?("#{controller.controller_name.singularize}/edit")
        options[:class] = "fa"
        options[:class] += " active" if is_active
        options[:data] ||= {}
        options[:data][:hook] = "admin_settings_#{link_text.downcase.tr(" ", "_")}"
        content_tag(:li, options) do
          link_to(link_text, url)
        end
      end
    end
  end
end
