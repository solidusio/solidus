module Spree
  module EventedInteractor
    def self.included(base)
      base.send :include, Interactor
      base.send :prepend, InteractorWrapper
    end

    private

    # These methods can be customized in the class that includes this module.
    # See for example Spree::Order::Interactors::Finalizer and the different
    # way of handling the event in Spree::Event::MailerProcessor for order_finalize
    # and reimbursement_perform
    def event_name
      self.class.name.underscore
    end

    def event_subject
      context
    end

    def event_payload
      if event_subject == context
        { subject: event_subject }
      else
        { subject: event_subject, context: context }
      end
    end

    # Metaprogramming is not the best for readability, but I think this is still clear
    %w[success error failure].each do |result|
      define_method "on_#{result}" do
        Spree::Event.instrument send("event_name_#{result}"), event_payload
      end

      define_method "event_name_#{result}" do
        [event_name, result].join('_')
      end
    end

    module InteractorWrapper
      def run!
        begin
          super
        rescue Interactor::Failure
          on_failure
          raise failure
        rescue
          on_error
          raise
        end
        on_success
      end
    end
  end
end
