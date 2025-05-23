# frozen_string_literal: true

module SolidusAdmin
  class TaxonomiesController < SolidusAdmin::BaseController
    include SolidusAdmin::ControllerHelpers::Search
    include SolidusAdmin::Moveable

    def index
      taxonomies = apply_search_to(
        Spree::Taxonomy.all,
        param: :q,
      )

      set_page_and_extract_portion_from(taxonomies)

      respond_to do |format|
        format.html { render component('taxonomies/index').new(page: @page) }
      end
    end

    def destroy
      @taxonomies = Spree::Taxonomy.where(id: params[:id])

      Spree::Taxonomy.transaction { @taxonomies.destroy_all }

      flash[:notice] = t('.success')
      redirect_back_or_to taxonomies_path, status: :see_other
    end
  end
end
