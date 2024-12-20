# frozen_string_literal: true

class Spree::ItemTotal
  def initialize(item)
    @item = item
  end

  def recalculate!
    item.adjustment_total = item.adjustments.reject(&:included?).sum(&:amount)
  end

  private

  attr_reader :item
end
