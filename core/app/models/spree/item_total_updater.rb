class Spree::ItemTotalUpdater
  class << self
    def recalculate(item)
      item.adjustment_total = item.adjustments
        .reject(&:included?)
        .sum(&:amount)
    end
  end
end
