module Solidus
  module Admin
    class StatesController < ResourceController
      belongs_to 'solidus/country'
      before_action :load_data

      def index
        respond_with(@collection) do |format|
          format.html
          format.js { render :partial => 'state_list' }
        end
      end

      private

        def location_after_save
          admin_country_states_url(@country)
        end

        def collection
          super.order(:name)
        end

        def load_data
          @countries = Country.order(:name)
        end
    end
  end
end
