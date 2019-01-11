module Spree
  module Presenter
    class Simple
      attr_reader :subject

      def initialize(subject)
        @subject = subject
      end
    end
  end
end
