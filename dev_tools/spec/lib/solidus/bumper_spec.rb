# frozen_string_literal: true

require 'solidus/bumper'
require 'tempfile'

RSpec.describe Solidus::Bumper do
  describe '.call' do
    around do |example|
      Tempfile.create('spree/core/version.rb') do |file|
        example.metadata[:file] = file

        example.run
      end
    end

    it 'bumps the version' do |e|
      file = e.metadata[:file]
      file.write <<~RUBY
        module Spree
          VERSION = "4.0.0.alpha"
        end
      RUBY
      file.rewind

      described_class.(
        from: '4.0.0.alpha',
        to: '4.0.0',
        path: file.path
      )

      expect(file.read).to eq <<~RUBY
        module Spree
          VERSION = "4.0.0"
        end
      RUBY
    end
  end
end
