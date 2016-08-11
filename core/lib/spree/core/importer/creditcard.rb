module Spree
  module Core
    module Importer
      class CreditCard
        def self.import(user, create_params)
          ActiveRecord::Base.transaction do
            credit_card = Spree::CreditCard.create! create_params
            credit_card.associate_user!(user)
            credit_card.save!

            credit_card.reload
          end

        end
      end
    end
  end
end
