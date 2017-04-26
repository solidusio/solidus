module Spree
  module Admin
    # A menus or tab bar in the admin
    class Menu
      attr_reader :items, :sections

      class Section < Struct.new(:menu, :name, :label, :icon)
        def items
          menu.items.select{|item| item.section_name == name }
        end
      end

      class Item < Struct.new(:menu, :handle, :label, :url, :condition)
        def section_name
          handle.split('/', 2)[0]
        end

        def name
          handle.split('/', 2)[1]
        end

        def label
          super || name
        end
      end

      def initialize()
        @sections = []
        @items = []
      end

      def add_section(name, label: nil, icon:)
        name = name.to_s
        label ||= name
        @sections << Section.new(self, name, label, icon)
      end

      def add_item(
        handle,
        condition: nil,
        label: nil,
        url: nil
      )
        condition ||= -> { true }
        @items << Item.new(self, handle, label, url, condition)
      end
    end
  end
end
