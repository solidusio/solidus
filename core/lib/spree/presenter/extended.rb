module Spree
  module Presenter
    class Extended < SimpleDelegator
      # CannotOverrideMethodError = Class.new(StandardError)
      #
      # attr_reader :subject
      #
      # def initialize(subject, **locals)
      #   @subject = subject
      #
      #   locals.each do |key, value|
      #     if subject.respond_to?(key)
      #       raise CannotOverrideMethodError.new("#{subject} already respond to #{key}!")
      #     end
      #
      #     define_singleton_method(key) { value }
      #   end
      #
      #   super(subject)
      # end
    end
  end
end
