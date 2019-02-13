module Spree
  module EventedInteractor
    def self.included(base)
      base.send :include, Interactor
      base.send :prepend, InteractorWrapper
    end

    private

    def on_success
      puts "success"
    end

    def on_error(error)
      puts "error"
    end

    def on_failure(failure)
      puts "failure"
    end

    module InteractorWrapper
      def run!
        begin
          super
        rescue Interactor::Failure => failure
          on_failure(failure)
          raise failure
        rescue => error
          on_error(error)
          raise error
        end
        on_success
      end
    end
  end
end
