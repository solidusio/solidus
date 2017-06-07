require 'spec_helper'

describe Spree::BillingResponse, type: :model do
  BillingResponse = Spree::BillingResponse
  AVSResult = Spree::AVSResult
  CVVResult = Spree::CVVResult

  describe '#initialize' do
    it 'sets attributes' do
      params = { foo: :bar }

      options = {
        error_code: 1,
        emv_authorization: 2,
        authorization: 3,
        test: true
      }

      response =
        BillingResponse.new(true, 'msg', params, options)

      expect(response.message).to eq('msg')
      expect(response.params).to eq({ "foo" => :bar })
      expect(response.error_code).to eq(1)
      expect(response.emv_authorization).to eq(2)
      expect(response.authorization).to eq(3)
      expect(response.test).to eq(true)
    end

    it 'setting avs_result as an AVSResult has the same result as a Hash' do
      avs_params = {}
      avs_result = AVSResult.new avs_params

      response1 =
        BillingResponse.new(true, "", {}, avs_result: avs_result)

      response2 =
        BillingResponse.new(true, "", {}, avs_result: avs_params)

      expect(response1.avs_result).to eq(response2.avs_result)
    end

    it 'setting cvs_result as an CVVResult has the same result as a Hash' do
      cvv_params = {}
      cvv_result = CVVResult.new cvv_params

      response1 =
        BillingResponse.new(true, "", {}, cvv_result: cvv_result)

      response2 =
        BillingResponse.new(true, "", {}, cvv_result: cvv_params)

      expect(response1.cvv_result).to eq(response2.cvv_result)
    end

    it 'sets @test to false by default' do
      response =
        BillingResponse.new(true, "", {}, {})

      expect(response.test).to be false
    end
  end

  describe '#success?' do
    it 'is the same as @success' do
      success =
        BillingResponse.new(true, "", {}, {})
      failure =
        BillingResponse.new(false, "", {}, {})

      expect(success.success?).to be true
      expect(failure.success?).to be false
    end
  end

  describe '#test?' do
    it 'is the same as @test' do
      test =
        BillingResponse.new(true, "", {}, { test: true })
      not_test =
        BillingResponse.new(true, "", {}, { test: false })

      expect(test.test?).to be true
      expect(not_test.test?).to be false
    end
  end

  describe '#fraud_review?' do
    it 'is the same as @fraud_review' do
      fraud_review =
        BillingResponse.new(true, "", {}, { fraud_review: true })
      not_fraud_review =
        BillingResponse.new(true, "", {}, { fraud_review: false })

      expect(fraud_review.fraud_review?).to be true
      expect(not_fraud_review.fraud_review?).to be false
    end
  end
end
