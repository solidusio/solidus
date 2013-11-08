module Spree
  module Admin
    TaxonsController.class_eval do
      private
        def permitted_params
          [
           :name, :parent_id, :position, :icon, :description, :permalink,
           :taxonomy_id, :meta_description, :meta_keywords, :meta_title,
           :translations_attributes => translations_attributes
          ]
        end

        def translations_attributes
          [:id, :locale, :name, :description, :permalink, :meta_description, :meta_keywords, :meta_title]
        end
    end
  end
end
