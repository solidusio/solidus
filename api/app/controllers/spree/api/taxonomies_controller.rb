# frozen_string_literal: true

module Spree
  module Api
    class TaxonomiesController < Spree::Api::BaseController
      def index
        @taxonomies = paginate(taxonomies)
        respond_with(@taxonomies)
      end

      def new
      end

      def show
        respond_with(taxonomy)
      end

      # Because JSTree wants parameters in a *slightly* different format
      def jstree
        Spree::Deprecation.warn("Please don't use `/api/taxonomies/:taxonomy_id/jstree` endpoint. It is deprecated and will be removed in the next future.", caller)
        show
      end

      def create
        authorize! :create, Taxonomy
        @taxonomy = Spree::Taxonomy.new(taxonomy_params)
        if @taxonomy.save
          respond_with(@taxonomy, status: 201, default_template: :show)
        else
          invalid_resource!(@taxonomy)
        end
      end

      def update
        authorize! :update, taxonomy
        if taxonomy.update(taxonomy_params)
          respond_with(taxonomy, status: 200, default_template: :show)
        else
          invalid_resource!(taxonomy)
        end
      end

      def destroy
        authorize! :destroy, taxonomy
        taxonomy.destroy
        respond_with(taxonomy, status: 204)
      end

      private

      def taxonomies
        @taxonomies = Taxonomy.
          accessible_by(current_ability, :read).
          order('name').
          includes(root: :children).
          ransack(params[:q]).
          result
      end

      def taxonomy
        @taxonomy ||= Spree::Taxonomy.accessible_by(current_ability, :read).
          includes(root: :children).
          find(params[:id])
      end

      def taxonomy_params
        if params[:taxonomy] && !params[:taxonomy].empty?
          params.require(:taxonomy).permit(permitted_taxonomy_attributes)
        else
          {}
        end
      end
    end
  end
end
