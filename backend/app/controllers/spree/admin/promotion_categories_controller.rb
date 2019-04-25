# frozen_string_literal: true

module Spree
  module Admin
    class PromotionCategoriesController < ResourceController
      before_action :set_breadcrumbs

      private

      def set_breadcrumbs
        add_breadcrumb plural_resource_name(Spree::Promotion), spree.admin_promotions_path
        add_breadcrumb plural_resource_name(Spree::PromotionCategory), spree.admin_promotion_categories_path
        add_breadcrumb @promotion_category.name if action_name == 'edit'
        add_breadcrumb t('spree.new_promotion_category') if action_name == 'new'
      end
    end
  end
end
