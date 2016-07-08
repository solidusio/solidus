module Spree
  class Gateway < PaymentMethod
    delegate :authorize, :purchase, :capture, :void, :credit, to: :provider

    validates :name, :type, presence: true

    preference :server, :string, default: 'test'
    preference :test_mode, :boolean, default: true

    def payment_source_class
      CreditCard
    end

    def provider
      gateway_options = options
      gateway_options.delete :login if gateway_options.key?(:login) && gateway_options[:login].nil?
      if gateway_options[:server]
        ActiveMerchant::Billing::Base.mode = gateway_options[:server].to_sym
      end
      @provider ||= provider_class.new(gateway_options)
    end

    def options
      preferences.to_hash
    end

    def payment_profiles_supported?
      false
    end

    def method_type
      'gateway'
    end

    def supports?(source)
      return true unless provider_class.respond_to? :supports?
      return true if source.brand && provider_class.supports?(source.brand)
      source.has_payment_profile?
    end

    def disable_customer_profile(source)
      Spree::Deprecation.warn("Gateway#disable_customer_profile is deprecated")
      if source.is_a? CreditCard
        source.update_column :gateway_customer_profile_id, nil
      else
        raise 'You must implement disable_customer_profile method for this gateway.'
      end
    end

    def sources_by_order(order)
      source_ids = order.payments.where(payment_method_id: id).pluck(:source_id).uniq
      payment_source_class.where(id: source_ids).with_payment_profile
    end

    def reusable_sources(order)
      if order.completed?
        sources_by_order(order)
      elsif order.user_id
        credit_cards.where(user_id: order.user_id).with_payment_profile
      else
        []
      end
    end
  end
end
