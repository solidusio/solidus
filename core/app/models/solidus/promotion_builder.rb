class Spree::PromotionBuilder
  include ActiveModel::Model

  attr_reader :promotion
  attr_accessor :base_code, :number_of_codes, :user

  validates :number_of_codes,
    numericality: { only_integer: true, greater_than: 0 },
    allow_nil: true

  validate :promotion_validity

  class_attribute :code_builder_class
  self.code_builder_class = ::Spree::PromotionCode::CodeBuilder

  # @param promotion_attrs [Hash] The desired attributes for the newly promotion
  # @param attributes [Hash] The desired attributes for this builder
  # @param user [Spree::User] The user who triggered this promotion build
  def initialize(attributes={}, promotion_attributes={})
    @promotion = Spree::Promotion.new(promotion_attributes)
    super(attributes)
  end

  def perform
    if can_build_codes?
      @promotion.codes = code_builder.build_promotion_codes
    end

    return false unless valid?

    @promotion.save
  end

  def number_of_codes= value
    @number_of_codes = value.presence.try(:to_i)
  end

  private

  def promotion_validity
    if !@promotion.valid?
      @promotion.errors.each do |attribute, error|
        errors[attribute].push error
      end
    end
  end

  def can_build_codes?
    @base_code && @number_of_codes
  end

  def code_builder
    self.class.code_builder_class.new(@promotion, @base_code, @number_of_codes)
  end
end
