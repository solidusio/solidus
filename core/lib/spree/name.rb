# frozen_string_literal: true

require 'active_support/core_ext/hash'

# Provides a value object to help transitioning from legacy
# firstname and lastname fields to a unified name field.
module Spree
  class Name
    attr_reader :first_name, :last_name, :full_name

    # Creates an instance of Spree::Name parsing input attributes.
    # @param attributes [Hash] an hash possibly containing name-related
    #   attributes (name, firstname, lastname, first_name, last_name)
    # @return [Spree::Name] the object created
    def self.from_attributes(attributes)
      params = attributes.with_indifferent_access

      if params[:name].present?
        Spree::Name.new(params[:name])
      elsif params[:firstname].present?
        Spree::Name.new(params[:firstname], params[:lastname])
      elsif params[:first_name].present?
        Spree::Name.new(params[:first_name], params[:last_name])
      else
        Spree::Name.new
      end
    end

    def initialize(*components)
      @full_name = components.join(' ').strip

      if components.size == 2
        @first_name = components[0].to_s
        @last_name = components[1].to_s
      else
        @first_name = @full_name.split(/[[:space:]]/, 2)[0]
        @last_name = @full_name.split(/[[:space:]]/, 2)[1]
      end
    end

    def to_s
      @full_name
    end
  end
end
