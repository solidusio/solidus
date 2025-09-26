# frozen_string_literal: true

module Spree
  module Admin
    class TaxonsController < Spree::Admin::BaseController
      rescue_from ActiveRecord::RecordNotFound, with: :resource_not_found
      respond_to :html, :json, :js

      def index
      end

      def search
        @taxons = if params[:ids]
          Spree::Taxon.where(id: params[:ids].split(","))
        else
          Spree::Taxon.limit(20).ransack(name_cont: params[:q]).result
        end
      end

      def create
        @taxonomy = Spree::Taxonomy.find(params[:taxonomy_id])
        @taxon = @taxonomy.taxons.build(params[:taxon])
        if @taxon.save
          respond_with(@taxon) do |format|
            format.json { render json: @taxon.to_json }
          end
        else
          flash[:error] = t("spree.errors.messages.could_not_create_taxon")
          respond_with(@taxon) do |format|
            format.html { redirect_to @taxonomy ? edit_admin_taxonomy_url(@taxonomy) : admin_taxonomies_url }
          end
        end
      end

      def edit
        @taxonomy = Spree::Taxonomy.find(params[:taxonomy_id])
        @taxon = @taxonomy.taxons.find(params[:id])
        @permalink_part = @taxon.permalink.split("/").last
      end

      def update
        @taxonomy = Spree::Taxonomy.find(params[:taxonomy_id])
        @taxon = @taxonomy.taxons.find(params[:id])
        parent_id = params[:taxon][:parent_id]
        new_position = params[:taxon][:position]

        if parent_id
          @taxon.parent = Spree::Taxon.find(parent_id.to_i)
        end

        if new_position
          @taxon.child_index = new_position.to_i
        end

        if params[:permalink_part]
          @taxon.permalink_part = params[:permalink_part].to_s
        end

        @taxon.assign_attributes(taxon_params)

        if @taxon.save
          flash[:success] = flash_message_for(@taxon, :successfully_updated)
        end

        respond_with(@taxon) do |format|
          format.html do
            if @taxon.valid?
              redirect_to edit_admin_taxonomy_url(@taxonomy)
            else
              render :edit
            end
          end
        end
      end

      def destroy
        @taxon = Spree::Taxon.find(params[:id])
        @taxon.destroy
        respond_with(@taxon) { |format| format.json { render json: "" } }
      end

      private

      def taxon_params
        params.require(:taxon).permit(permitted_taxon_attributes)
      end

      def resource_not_found
        super(flash_class: Taxon, redirect_url: admin_taxonomies_path)
      end
    end
  end
end
