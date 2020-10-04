# frozen_string_literal: true

Spree::StockLocation.create_with(backorderable_default: true)
                    .find_or_create_by!(name: 'default')
