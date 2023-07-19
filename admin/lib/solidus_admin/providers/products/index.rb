require "solidus_admin/container"

module SolidusAdmin
  module Providers
    Container.register_provider("products.index") do
      start do
        SolidusAdmin::Config.products.index do |columns|
          columns.add(
            name: :image,
            header: :image,
            data: -> { [_1.id, _1.gallery.images.first] },
            position: 10
          )
          columns.add(
            name: :name,
            header: :name,
            data: -> { [_1.id, _1.name] },
            position: 20
          )
          columns.add(
            name: :status,
            header: :status,
            data: -> { _1.available? },
            position: 30
          )
          columns.add(
            name: :stock,
            header: :stock,
            data: -> { [_1.total_on_hand, _1.variants.count] },
            position: 40
          )
          columns.add(
            name: :price,
            header: :price,
            data: -> { _1.master.display_price },
            position: 50
          )
        end

        container.register("products.index") do
          Container.within_namespace("products.index")
        end
      end
    end
  end
end
