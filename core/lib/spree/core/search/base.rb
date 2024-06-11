# frozen_string_literal: true

module Spree
  module Core
    module Search
      class Base
        class InvalidOptions < ArgumentError
          def initialize(option)
            super("Invalid option passed to the searcher: '#{option}'")
          end
        end

        attr_accessor :properties
        attr_accessor :current_user
        attr_accessor :pricing_options

        def initialize(params)
          self.pricing_options = Spree::Config.default_pricing_options
          @properties = {}
          prepare(params)
        end

        def retrieve_products
          @products = get_base_scope
          curr_page = @properties[:page] || 1

          unless Spree::Config.show_products_without_price
            @products = @products.joins(:prices).merge(Spree::Price.where(pricing_options.search_arguments)).distinct
          end
          @products = @products.page(curr_page).per(@properties[:per_page])
        end

        protected

        def get_base_scope
          base_scope = Spree::Product.display_includes.available
          base_scope = base_scope.in_taxon(@properties[:taxon]) unless @properties[:taxon].blank?
          base_scope = get_products_conditions_for(base_scope, @properties[:keywords])
          base_scope = add_search_scopes(base_scope)
          base_scope = add_eagerload_scopes(base_scope)
          base_scope
        end

        def add_eagerload_scopes(scope)
          # TL;DR Switch from `preload` to `includes` as soon as Rails starts honoring
          # `order` clauses on `has_many` associations when a `where` constraint
          # affecting a joined table is present (see
          # https://github.com/rails/rails/issues/6769).
          #
          # Ideally this would use `includes` instead of `preload` calls, leaving it
          # up to Rails whether associated objects should be fetched in one big join
          # or multiple independent queries. However as of Rails 4.1.8 any `order`
          # defined on `has_many` associations are ignored when Rails builds a join
          # query.
          #
          # Would we use `includes` in this particular case, Rails would do
          # separate queries most of the time but opt for a join as soon as any
          # `where` constraints affecting joined tables are added to the search;
          # which is the case as soon as a taxon is added to the base scope.
          scope = scope.preload(master: :prices)
          scope = scope.preload(master: :images) if @properties[:include_images]
          scope
        end

        def add_search_scopes(base_scope)
          return base_scope unless @properties[:search].present?
          raise InvalidOptions.new(:search) unless @properties[:search].respond_to?(:each_pair)

          @properties[:search].each_pair do |name, scope_attribute|
            scope_name = name.to_sym

            if base_scope.respond_to?(:search_scopes) && base_scope.search_scopes.include?(scope_name.to_sym)
              base_scope = base_scope.send(scope_name, *scope_attribute)
            else
              base_scope = base_scope.merge(Spree::Product.ransack({ scope_name => scope_attribute }).result)
            end
          end

          base_scope
        end

        # method should return new scope based on base_scope
        def get_products_conditions_for(base_scope, query)
          unless query.blank?
            base_scope = base_scope.like_any([:name, :description], query.split)
          end
          base_scope
        end

        def prepare(params)
          @properties[:taxon] = params[:taxon].blank? ? nil : Spree::Taxon.find(params[:taxon])
          @properties[:keywords] = params[:keywords]
          @properties[:search] = params[:search]
          @properties[:include_images] = params[:include_images]

          per_page = params[:per_page].to_i
          @properties[:per_page] = per_page > 0 ? per_page : Spree::Config[:products_per_page]
          @properties[:page] = (params[:page].to_i <= 0) ? 1 : params[:page].to_i
        end
      end
    end
  end
end
