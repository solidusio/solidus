# frozen_string_literal: true

module SolidusAdmin
  class TaxonomiesController < SolidusAdmin::BaseController
    before_action :load_taxonomy, only: [:move]

    def index
      @taxonomies = Spree::Taxonomy.all

      respond_to do |format|
        format.html { render component('taxonomies/index').new(taxonomies: @taxonomies) }
      end
    end

    def move
      @taxonomy.insert_at(params[:position].to_i)

      respond_to do |format|
        format.js { head :no_content }
      end
    end

    def destroy
      @taxonomies = Spree::Taxonomy.where(id: params[:id])

      Spree::Taxonomy.transaction { @taxonomies.destroy_all }

      flash[:notice] = t('.success')
      redirect_back_or_to taxonomies_path, status: :see_other
    end

    private

    def load_taxonomy
      @taxonomy = Spree::Taxonomy.find(params[:id])
      authorize! action_name, @taxonomy
    end
  end
end
