module Spree
  module Core::ControllerHelpers::PaymentParameters
    # This method handles the awkwardness of how the html forms are currently
    # set up for frontend and admin.
    #
    # This method expects a params hash in the format of:
    #
    #  {
    #    payment_source: {
    #      # The keys here are spree_payment_method.id's
    #      '1' => {...source attributes for payment method 1...},
    #      '2' => {...source attributes for payment method 2...},
    #    },
    #    order: {
    #      # Note that only a single entry is expected/handled in this array
    #      payments_attributes: [
    #        {
    #          payment_method_id: '1',
    #        },
    #      ],
    #      ...other params...
    #    },
    #    ...other params...
    #  }
    #
    # And this method returns a new params hash in the format of:
    #
    #  {
    #    order: {
    #      payments_attributes: [
    #        {
    #          payment_method_id: '1',
    #          source_attributes: {...source attributes for payment method 1...}
    #        },
    #      ],
    #      ...other params...
    #    },
    #    ...other params...
    #  }
    #
    def move_payment_source_into_payments_attributes(original_params)
      params = original_params.deep_dup

      # Step 1: Gather all the information and ensure all the pieces are there.

      return params if params[:payment_source].blank?

      payment_params = params[:order] &&
        params[:order][:payments_attributes] &&
        params[:order][:payments_attributes].first
      return params if payment_params.blank?

      payment_method_id = payment_params[:payment_method_id]
      return params if payment_method_id.blank?

      source_params = params[:payment_source][payment_method_id]
      return params if source_params.blank?

      # Step 2: Perform the modifications.

      payment_params[:source_attributes] = source_params
      params.delete(:payment_source)

      params
    end
  end
end
