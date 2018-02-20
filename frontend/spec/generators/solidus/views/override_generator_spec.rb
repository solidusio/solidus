# frozen_string_literal: true

require 'spec_helper'
require 'generator_spec'
require 'generators/solidus/views/override_generator'

RSpec.describe Solidus::Views::OverrideGenerator, type: :generator do
  destination Rails.root.join('app', 'views', 'spree')

  before(:all) do
    prepare_destination
  end

  subject! do
    run_generator arguments
  end

  let(:src) do
    Spree::Frontend::Engine.root.join('app', 'views', 'spree')
  end

  let(:dest) do
    Rails.root.join('app', 'views', 'spree')
  end

  context 'without any arguments' do
    let(:arguments) { %w() }

    it 'copies all views into the host app' do
      expect(src.entries).to match_array(dest.entries)
    end
  end

  context 'when "products" is passed as --only argument' do
    let(:arguments) { %w(--only products) }

    context 'as folder' do
      it 'exclusively copies views whose name contains "products"' do
        Dir.glob(dest.join("**", "*")).each do |file|
          next if File.directory?(file)
          expect(file.to_s).to match("products")
        end
      end
    end
  end

  after do
    FileUtils.rm_rf destination_root
  end
end
