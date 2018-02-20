# frozen_string_literal: true

json.attributes(([*line_item_attributes] - [:id]))
json.required_attributes([:variant_id, :quantity])
