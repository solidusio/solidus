module Spree
  module BaseHelper
    def link_to_cart(text = nil)
      text = text ? h(text) : Spree.t(:cart)
      css_class = nil

      if simple_current_order.nil? || simple_current_order.item_count.zero?
        text = "#{text}: (#{Spree.t(:empty)})"
        css_class = 'empty'
      else
        text = "#{text}: (#{simple_current_order.item_count})  <span class='amount'>#{simple_current_order.display_total.to_html}</span>"
        css_class = 'full'
      end

      link_to text.html_safe, spree.cart_path, class: "cart-info #{css_class}"
    end

    # human readable list of variant options
    def variant_options(v, _options = {})
      v.options_text
    end

    def meta_data
      object = instance_variable_get('@' + controller_name.singularize)
      meta = {}

      if object.is_a? ActiveRecord::Base
        meta[:keywords] = object.meta_keywords if object[:meta_keywords].present?
        meta[:description] = object.meta_description if object[:meta_description].present?
      end

      if meta[:description].blank? && object.is_a?(Spree::Product)
        meta[:description] = truncate(strip_tags(object.description), length: 160, separator: ' ')
      end

      meta.reverse_merge!({
        keywords: current_store.meta_keywords,
        description: current_store.meta_description
      }) if meta[:keywords].blank? || meta[:description].blank?
      meta
    end

    def meta_data_tags
      meta_data.map do |name, content|
        tag('meta', name: name, content: content)
      end.join("\n")
    end

    def body_class
      @body_class ||= content_for?(:sidebar) ? 'two-col' : 'one-col'
      @body_class
    end

    def logo(image_path = Spree::Config[:logo])
      link_to image_tag(image_path), spree.root_path
    end

    def flash_messages(opts = {})
      ignore_types = ["order_completed"].concat(Array(opts[:ignore_types]).map(&:to_s) || [])

      flash.each do |msg_type, text|
        unless ignore_types.include?(msg_type)
          concat(content_tag(:div, text, class: "flash #{msg_type}"))
        end
      end
      nil
    end

    def taxon_breadcrumbs(taxon, separator = "&nbsp;&raquo;&nbsp;", breadcrumb_class = "inline")
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
        content_tag(:li, itemscope: "itemscope", itemtype: "http://data-vocabulary.org/Breadcrumb") do
          link_to(crumb.last, itemprop: "url") do
            content_tag(:span, crumb.first, itemprop: "title")
          end + (crumb == crumbs.last ? '' : separator)
        end
      end

      content_tag(:nav, content_tag(:ul, raw(crumbs.map(&:mb_chars).join), class: breadcrumb_class), id: 'breadcrumbs', class: 'sixteen columns')
    end

    def taxons_tree(root_taxon, current_taxon, max_level = 1)
      return '' if max_level < 1 || root_taxon.children.empty?
      content_tag :ul, class: 'taxons-list' do
        taxons = root_taxon.children.map do |taxon|
          css_class = (current_taxon && current_taxon.self_and_ancestors.include?(taxon)) ? 'current' : nil
          content_tag :li, class: css_class do
           link_to(taxon.name, seo_url(taxon)) +
             taxons_tree(taxon, current_taxon, max_level - 1)
          end
        end
        safe_join(taxons, "\n")
      end
    end

    def available_countries
      checkout_zone = Zone.find_by(name: Spree::Config[:checkout_zone])

      if checkout_zone && checkout_zone.kind == 'country'
        countries = checkout_zone.country_list
      else
        countries = Country.all
      end

      countries.collect do |country|
        country.name = Spree.t(country.iso, scope: 'country_names', default: country.name)
        country
      end.sort_by { |c| c.name.parameterize }
    end

    def seo_url(taxon)
      spree.nested_taxons_path(taxon.permalink)
    end

    def display_price(product_or_variant)
      product_or_variant.price_for(current_pricing_options).to_html
    end

    def pretty_time(time)
      [I18n.l(time.to_date, format: :long),
       time.strftime("%l:%M %p")].join(" ")
    end

    def method_missing(method_name, *args, &block)
      if image_style = image_style_from_method_name(method_name)
        define_image_method(image_style)
        send(method_name, *args)
      else
        super
      end
    end

    def link_to_tracking(shipment, options = {})
      return unless shipment.tracking && shipment.shipping_method

      if shipment.tracking_url
        link_to(shipment.tracking, shipment.tracking_url, options)
      else
        content_tag(:span, shipment.tracking)
      end
    end

    def plural_resource_name(resource_class)
      resource_class.model_name.human(count: Spree::I18N_GENERIC_PLURAL)
    end

    private

    # Returns style of image or nil
    def image_style_from_method_name(method_name)
      if method_name.to_s.match(/_image$/) && style = method_name.to_s.sub(/_image$/, '')
        possible_styles = Spree::Image.attachment_definitions[:attachment][:styles]
        style if style.in? possible_styles.with_indifferent_access
      end
    end

    def create_product_image_tag(image, product, options, style)
      options.reverse_merge! alt: image.alt.blank? ? product.name : image.alt
      image_tag image.attachment.url(style), options
    end

    def define_image_method(style)
      self.class.send :define_method, "#{style}_image" do |product, *options|
        Spree::Deprecation.warn "Spree image helpers will be deprecated in the near future. Use the provided resource to access the intendend image directly.", caller
        options = options.first || {}
        if product.images.empty?
          if !product.is_a?(Spree::Variant) && !product.variant_images.empty?
            create_product_image_tag(product.variant_images.first, product, options, style)
          elsif product.is_a?(Variant) && !product.product.variant_images.empty?
            create_product_image_tag(product.product.variant_images.first, product, options, style)
          else
            image_tag "noimage/#{style}.png", options
          end
        else
          create_product_image_tag(product.images.first, product, options, style)
        end
      end
    end
  end
end
