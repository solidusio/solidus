# frozen_string_literal: true

CSV.generate do |csv|
  csv << ['Code']
  @promotion_codes.order(:id).pluck(:value).each do |value|
    csv << [value]
  end
end
