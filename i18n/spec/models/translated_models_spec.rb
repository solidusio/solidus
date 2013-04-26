require 'spec_helper'

module Spree
  describe Product do
    include_context "behaves as translatable"
  end

  describe OptionType do
    include_context "behaves as translatable"
  end

  describe Taxon do
    include_context "behaves as translatable"
  end

  describe Taxonomy do
    include_context "behaves as translatable"
  end

  describe Promotion do
    include_context "behaves as translatable"
  end

  describe Property do
    include_context "behaves as translatable"
  end
end
