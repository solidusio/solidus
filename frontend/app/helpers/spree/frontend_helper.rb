module Spree
  module FrontendHelper
    def body_class
      @body_class ||= content_for?(:sidebar) ? 'two-col' : 'one-col'
      @body_class
    end

    def breadcrumbs(taxon, separator="&nbsp;&raquo;&nbsp;", breadcrumb_class="inline")
      return "" if current_page?("/") || taxon.nil?

      crumbs = [[Spree.t(:home), spree.root_path]]

      if taxon
        crumbs << [Spree.t(:products), products_path]
        crumbs += taxon.ancestors.collect { |a| [a.name, spree.nested_taxons_path(a.permalink)] } unless taxon.ancestors.empty?
        crumbs << [taxon.name, spree.nested_taxons_path(taxon.permalink)]
      else
        crumbs << [Spree.t(:products), products_path]
      end

      separator = raw(separator)

      crumbs.map! do |crumb|
        content_tag(:li, itemscope:"itemscope", itemtype:"http://data-vocabulary.org/Breadcrumb") do
          link_to(crumb.last, itemprop: "url") do
            content_tag(:span, crumb.first, itemprop: "title")
          end + (crumb == crumbs.last ? '' : separator)
        end
      end

      content_tag(:nav, content_tag(:ul, raw(crumbs.map(&:mb_chars).join), class: breadcrumb_class), id: 'breadcrumbs', class: 'sixteen columns')
    end

    def checkout_states
      @order.checkout_steps
    end

    def checkout_progress
      states = checkout_states
      items = states.map do |state|
        text = Spree.t("order_state.#{state}").titleize

        css_classes = []
        current_index = states.index(@order.state)
        state_index = states.index(state)

        if state_index < current_index
          css_classes << 'completed'
          text = link_to text, checkout_state_path(state)
        end

        css_classes << 'next' if state_index == current_index + 1
        css_classes << 'current' if state == @order.state
        css_classes << 'first' if state_index == 0
        css_classes << 'last' if state_index == states.length - 1
        # It'd be nice to have separate classes but combining them with a dash helps out for IE6 which only sees the last class
        content_tag('li', content_tag('span', text), class: css_classes.join('-'))
      end
      content_tag('ol', raw(items.join("\n")), class: 'progress-steps', id: "checkout-step-#{@order.state}")
    end

    def flash_messages(opts = {})
      ignore_types = ["order_completed"].concat(Array(opts[:ignore_types]).map(&:to_s) || [])

      flash.each do |msg_type, text|
        unless ignore_types.include?(msg_type)
          concat(content_tag :div, text, class: "flash #{msg_type}")
        end
      end
      nil
    end

    def link_to_cart(text = nil)
      text = text ? h(text) : Spree.t(:cart)
      css_class = nil

      if simple_current_order.nil? or simple_current_order.item_count.zero?
        text = "#{text}: (#{Spree.t(:empty)})"
        css_class = 'empty'
      else
        text = "#{text}: (#{simple_current_order.item_count})  <span class='amount'>#{simple_current_order.display_total.to_html}</span>"
        css_class = 'full'
      end

      link_to text.html_safe, spree.cart_path, :class => "cart-info #{css_class}"
    end

    # @return [Boolean] true when it is appropriate to show the store menu
    def store_menu?
      %w{thank_you}.exclude? params[:action]
    end

    def taxons_tree(root_taxon, current_taxon, max_level = 1)
      return '' if max_level < 1 || root_taxon.children.empty?
      content_tag :ul, class: 'taxons-list' do
        root_taxon.children.map do |taxon|
          css_class = (current_taxon && current_taxon.self_and_ancestors.include?(taxon)) ? 'current' : nil
          content_tag :li, class: css_class do
           link_to(taxon.name, seo_url(taxon)) +
           taxons_tree(taxon, current_taxon, max_level - 1)
          end
        end.join("\n").html_safe
      end
    end

    def meta_data
      object = instance_variable_get('@'+controller_name.singularize)
      meta = {}

      if object.kind_of? ActiveRecord::Base
        meta[:keywords] = object.meta_keywords if object[:meta_keywords].present?
        meta[:description] = object.meta_description if object[:meta_description].present?
      end

      if meta[:description].blank? && object.kind_of?(Spree::Product)
        meta[:description] = strip_tags(truncate(object.description, length: 160, separator: ' '))
      end

      meta.reverse_merge!({
        keywords: current_store.meta_keywords,
        description: current_store.meta_description,
      }) if meta[:keywords].blank? or meta[:description].blank?
      meta
    end

    def meta_data_tags
      meta_data.map do |name, content|
        tag('meta', name: name, content: content)
      end.join("\n")
    end

    def logo(image_path=Spree::Config[:logo])
      link_to image_tag(image_path), spree.root_path
    end

    def seo_url(taxon)
      return spree.nested_taxons_path(taxon.permalink)
    end
  end
end
