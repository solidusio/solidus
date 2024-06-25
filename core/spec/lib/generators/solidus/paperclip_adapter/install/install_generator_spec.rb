# frozen_string_literal: true

require 'rails_helper'
require 'generators/solidus/paperclip_adapter/install/install_generator'

RSpec.describe Solidus::PaperclipAdapter::InstallGenerator do
  let(:initializer_directory) { Rails.root.join('tmp') }
  let(:initializer_basename) { 'spree' }
  let(:initializer) { File.join(initializer_directory, "#{initializer_basename}.rb") }
  let(:image_adapter_path) { Rails.root.join('app', 'models', 'my_store', 'image', 'paperclip_attachment.rb') }
  let(:taxon_adapter_path) { Rails.root.join('app', 'models', 'my_store', 'taxon', 'paperclip_attachment.rb') }
  let(:cleanup) {
    proc {
      File.delete(initializer) if File.exist?(initializer)
      File.delete(image_adapter_path) if File.exist?(image_adapter_path)
      File.delete(taxon_adapter_path) if File.exist?(taxon_adapter_path)
    }
  }
  let(:create_initializer) {
    proc {
      File.write(initializer,
        <<~RUBY
          Spree.config do |config|
            # ...
            #
            # Configure adapter for attachments on products and taxons (use ActiveStorageAttachment or PaperclipAttachment)
            config.image_attachment_module = 'Spree::Image::PaperclipAttachment'
            config.taxon_attachment_module = 'Spree::Taxon::PaperclipAttachment'
          end
        RUBY
      )
    }
  }
  let(:invoke) do
    lambda do
      Rails::Generators.invoke('solidus:paperclip_adapter:install', [
        "--initializer_directory=tmp",
        "--initializer_basename=spree",
        "--app_directory=#{Rails.root}",
        "--app_name=MyStore",
        "--quiet"
      ])
    end
  end

  before { create_initializer.call }
  after { cleanup.call }

  it 'changes attachment adapter configuration' do
    invoke.call

    expect(File.read(initializer)).to include(
      <<~RUBY
        Spree.config do |config|
          # ...
          #
          # Configure adapter for attachments on products and taxons (use ActiveStorageAttachment or PaperclipAttachment)
          config.image_attachment_module = 'MyStore::Image::PaperclipAttachment'
          config.taxon_attachment_module = 'MyStore::Taxon::PaperclipAttachment'
        end
      RUBY
    )
  end

  it 'copies adapter files at the right location' do
    invoke.call

    image_adapter_path = Rails.root.join('app', 'models', 'my_store', 'image', 'paperclip_attachment.rb')
    expect(File.read(image_adapter_path)).to include(
      <<~RUBY
        module MyStore
          module Image
            module PaperclipAttachment
      RUBY
    )

    expect(File.read(taxon_adapter_path)).to include(
      <<~RUBY
        module MyStore
          module Taxon
            module PaperclipAttachment
      RUBY
    )
  end
end
