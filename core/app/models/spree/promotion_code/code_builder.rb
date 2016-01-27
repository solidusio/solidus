# A class responsible for building PromotionCodes
class ::Spree::PromotionCode::CodeBuilder
  attr_reader :promotion, :num_codes, :base_code

  class_attribute :random_code_length
  self.random_code_length = 6

  # Requres a +promotion+, +base_code+ and +num_codes+
  #
  # +promotion+ Must be a Spree::Promotion.
  # +base_code+ Must be a String.
  # +num_codes+ Must be a positive integer greater than zero.
  def initialize(promotion, base_code, num_codes)
    @base_code = base_code
    @num_codes = num_codes
    @promotion = promotion
  end

  # Builds and returns an array of Spree::PromotionCode's
  def build_promotion_codes
    codes.map do |code|
      promotion.codes.build(value: code)
    end
  end

  private

  def codes
    if num_codes > 1
      generate_random_codes
    else
      [base_code]
    end
  end

  def generate_random_codes
    valid_codes = Set.new

    while valid_codes.size < num_codes
      new_codes = Array.new(num_codes) { generate_random_code }.to_set
      valid_codes += get_unique_codes(new_codes)
    end

    valid_codes.to_a.take(num_codes)
  end

  def generate_random_code
    suffix = Array.new(self.class.random_code_length) do
      sample_characters.sample
    end.join

    "#{@base_code}_#{suffix}"
  end

  def sample_characters
    @sample_characters ||= ('a'..'z').to_a
  end

  def get_unique_codes(code_set)
    code_set - Spree::PromotionCode.where(value: code_set.to_a).pluck(:value)
  end
end
