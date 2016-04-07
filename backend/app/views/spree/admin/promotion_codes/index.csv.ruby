CSV.generate do |csv|
  csv << ['Code']
  @promotion.codes.order(:id).pluck(:value).each do |value|
    csv << [value]
  end
end
