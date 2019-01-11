module Spree
  module Presenter
    class Delegated < SimpleDelegator
      attr_reader :subject

      def initialize(subject)
        @subject = subject

        super(subject)
      end
    end
  end
end
