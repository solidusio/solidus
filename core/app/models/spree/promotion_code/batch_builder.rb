class ::Spree::PromotionCode::BatchBuilder
  attr_reader :promotion_code_batch
  delegate :promotion, :number_of_codes, :base_code, to: :promotion_code_batch

  class_attribute :random_code_length, :batch_size, :sample_characters, :join_characters
  self.random_code_length = 6
  self.batch_size = 1_000
  self.sample_characters = ('a'..'z').to_a + (2..9).to_a.map(&:to_s)
  self.join_characters = "_"

  def initialize(promotion_code_batch)
    @promotion_code_batch = promotion_code_batch
  end

  def build_promotion_codes
    generate_random_codes
    promotion_code_batch.update!(state: "completed")
  rescue => e
    promotion_code_batch.update!(
      error: e.inspect,
      state: "failed"
    )
    raise e
  end

  private

  def generate_random_codes
    created_codes = 0

    while created_codes < number_of_codes
      max_codes_to_generate = [self.class.batch_size, number_of_codes - created_codes].min

      new_codes = Array.new(max_codes_to_generate) { generate_random_code }.uniq
      codes_for_current_batch = get_unique_codes(new_codes)

      codes_for_current_batch.each do |value|
        Spree::PromotionCode.create!(
          value: value,
          promotion: promotion,
          promotion_code_batch: promotion_code_batch
        )
      end
      created_codes += codes_for_current_batch.size
    end
  end

  def generate_random_code
    suffix = Array.new(self.class.random_code_length) do
      sample_characters.sample
    end.join

    "#{base_code}#{join_characters}#{suffix}"
  end

  def get_unique_codes(code_set)
    code_set - Spree::PromotionCode.where(value: code_set.to_a).pluck(:value)
  end
end
