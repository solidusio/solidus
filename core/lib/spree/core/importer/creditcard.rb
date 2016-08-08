module Spree
  module Core
    module Importer
      class CreditCard

        def initialize(creditcard, user_id, creditcard_params)
          @creditcard = creditcard || Spree::CreditCard.new(creditcard_params)
        end

        def create
          @creditcard.save!
          @creditcard
        end

      end
    end
  end
end
