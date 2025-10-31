# frozen_string_literal: true

module Spree
  class Calculator < Spree::Base
    include Spree::Preferences::Persistable

    belongs_to :calculable, polymorphic: true, optional: true

    # This method calls a compute_<computable> method. must be overriden in concrete calculator.
    #
    # It should return amount computed based on #calculable and the computable parameter
    def compute(computable, ...)
      # Spree::LineItem -> :compute_line_item
      computable_name = computable.class.name.demodulize.underscore
      method_name = :"compute_#{computable_name}"
      calculator_class = self.class
      if respond_to?(method_name)
        send(method_name, computable, ...)
      else
        raise NotImplementedError, "Please implement '#{method_name}(#{computable_name})' in your calculator: #{calculator_class.name}"
      end
    end

    # A description for this calculator in few words
    # @return [String] A description for the calculator
    def self.description
      model_name.human
    end

    ###################################################################

    def to_s
      self.class.name.titleize.gsub("Calculator\/", "")
    end

    def description
      self.class.description
    end

    def available?(_object)
      true
    end
  end
end
