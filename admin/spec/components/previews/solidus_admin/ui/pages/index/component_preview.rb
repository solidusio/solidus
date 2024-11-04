# frozen_string_literal: true

# @component "ui/pages/index"
class SolidusAdmin::UI::Pages::Index::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    records = Spree::Order.all
    page = GearedPagination::Recordset.new(records).page(1)

    component_subclcass = Class.new(component("ui/pages/index")) do
      def self.name
        "SolidusAdmin::MyIndex::Component"
      end

      def model_class
        Spree::Order
      end

      def search_key
        :number_cont
      end

      def search_url
        "/admin/orders"
      end

      def columns
        [:number]
      end

      def page_actions
        render component("ui/button").new(
          tag: :a,
          text: t('.add'),
          href: spree.new_admin_order_path,
          icon: "add-line",
        )
      end

      def batch_actions
        [{
          label: "Print",
          action: "print",
        }]
      end
    end

    render component_subclcass.new(page:)
  end
end
