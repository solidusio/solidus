module Spree
  class BillingResponse
    attr_reader(
      :params,
      :message,
      :test,
      :authorization,
      :avs_result,
      :cvv_result,
      :error_code,
      :emv_authorization
    )

    def success?
      @success
    end

    def test?
      @test
    end

    def fraud_review?
      @fraud_review
    end

    def initialize(success, message, params = {}, options = {})
      @success, @message, @params = success, message, params.stringify_keys
      @test = options[:test] || false
      @authorization = options[:authorization]
      @fraud_review = options[:fraud_review]
      @error_code = options[:error_code]
      @emv_authorization = options[:emv_authorization]

      @avs_result =
        if options[:avs_result].is_a?(AVSResult)
          options[:avs_result].to_hash
        else
          AVSResult.new(options[:avs_result]).to_hash
        end

      @cvv_result =
        if options[:cvv_result].is_a?(CVVResult)
          options[:cvv_result].to_hash
        else
          CVVResult.new(options[:cvv_result]).to_hash
        end
    end
  end
end
