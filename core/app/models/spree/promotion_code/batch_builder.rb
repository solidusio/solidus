# frozen_string_literal: true

class ::Spree::PromotionCode::BatchBuilder
  attr_reader :promotion_code_batch, :options
  delegate :promotion, :number_of_codes, :base_code, to: :promotion_code_batch

  DEFAULT_OPTIONS = {
    random_code_length: 6,
    batch_size: 1000,
    sample_characters: ('a'..'z').to_a + (2..9).to_a.map(&:to_s)
  }

  [:random_code_length, :batch_size, :sample_characters].each do |attr|
    define_singleton_method(attr) do
      Spree::Deprecation.warn "#{name}.#{attr} is deprecated. Use #{name}::DEFAULT_OPTIONS[:#{attr}] instead"
      DEFAULT_OPTIONS[attr]
    end

    define_singleton_method(:"#{attr}=") do |val|
      Spree::Deprecation.warn "#{name}.#{attr}= is deprecated. Use #{name}::DEFAULT_OPTIONS[:#{attr}]= instead"
      DEFAULT_OPTIONS[attr] = val
    end

    delegate attr, to: self
  end

  def initialize(promotion_code_batch, options = {})
    @promotion_code_batch = promotion_code_batch
    options.assert_valid_keys(*DEFAULT_OPTIONS.keys)
    @options = DEFAULT_OPTIONS.merge(options)
  end

  def build_promotion_codes
    generate_random_codes
    promotion_code_batch.update!(state: "completed")
  rescue StandardError => error
    promotion_code_batch.update!(
      error: error.inspect,
      state: "failed"
    )
    raise error
  end

  private

  def generate_random_codes
    created_codes = 0
    batch_size = @options[:batch_size]

    while created_codes < number_of_codes
      max_codes_to_generate = [batch_size, number_of_codes - created_codes].min

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
    suffix = Array.new(@options[:random_code_length]) do
      @options[:sample_characters].sample
    end.join

    "#{base_code}#{@promotion_code_batch.join_characters}#{suffix}"
  end

  def get_unique_codes(code_set)
    code_set - Spree::PromotionCode.where(value: code_set.to_a).pluck(:value)
  end
end
