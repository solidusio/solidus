module Spree
  # Result of the Card Verification Value check
  # http://www.bbbonline.org/eExport/doc/MerchantGuide_cvv2.pdf
  # Check additional codes from cybersource website
  class CVVResult
    MESSAGES = {
      'D'  =>  'CVV check flagged transaction as suspicious',
      'I'  =>  'CVV failed data validation check',
      'M'  =>  'CVV matches',
      'N'  =>  'CVV does not match',
      'P'  =>  'CVV not processed',
      'S'  =>  'CVV should have been present',
      'U'  =>  'CVV request unable to be processed by issuer',
      'X'  =>  'CVV check not supported for card'
    }

    def self.messages
      MESSAGES
    end

    attr_reader :code, :message

    def initialize(code)
      @code = (code.blank? ? nil : code.upcase)
      @message = MESSAGES[@code]
    end

    def to_hash
      {
        'code' => code,
        'message' => message
      }
    end
  end
end
