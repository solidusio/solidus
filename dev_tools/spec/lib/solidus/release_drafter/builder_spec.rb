# frozen_string_literal: true

require 'solidus/release_drafter/builder'
require 'solidus/release_drafter/draft'

RSpec.describe Solidus::ReleaseDrafter::Builder do
  let(:core) { 'Solidus Core' }
  let(:backend) { 'Solidus Backend' }
  let(:api) { 'Solidus API' }
  let(:categories) { [core, backend, api] }
  let(:number_link_builder) { ->(number) { "https://github.com/solidusio/solidus/pull/#{number}" } }
  let(:user_link_builder) { ->(author) { "https://github.com/#{author}" } }
  let(:entry) { ->(title, number, user) { "- #{title} [##{number}](#{number_link_builder.(number)}) ([@#{user}](#{user_link_builder.(user)}))" } }

  describe '#initialize' do
    context 'for an existing draft' do
      it "raises when categories doesn't match" do
        content = <<~TXT.chomp
          ## Solidus Core
          #{entry.('Old entry', 9, 'bob')}

          ## Solidus Backend
        TXT
        draft = Solidus::ReleaseDrafter::Draft.new(url: 'https://release.com', content: content)

        expect {
          described_class.new(draft: draft, categories: categories, number_link_builder: number_link_builder, user_link_builder: user_link_builder)
        }.to raise_error(/Given categories don't match those found in the draft/)
      end

      it 'raises when prepended text is not present' do
        content = <<~TXT.chomp
          ## Solidus Core
          #{entry.('Old entry 1', 9, 'bob')}

          ## Solidus Backend

          ## Solidus API
          #{entry.('Old entry 2', 8, 'alice')}
        TXT
        draft = Solidus::ReleaseDrafter::Draft.new(url: 'https://release.com', content: content)

        expect {
          described_class.new(draft: draft, categories: categories, prepend: "## List of changes\n\n", number_link_builder: number_link_builder, user_link_builder: user_link_builder)
        }.to raise_error(/Prepended text is not present in the draft/)
      end

      it 'raises when appended text is not present' do
        content = <<~TXT.chomp
          ## Solidus Core
          #{entry.('Old entry 1', 9, 'bob')}

          ## Solidus Backend

          ## Solidus API
          #{entry.('Old entry 2', 8, 'alice')}
        TXT
        draft = Solidus::ReleaseDrafter::Draft.new(url: 'https://release.com', content: content)

        expect {
          described_class.new(draft: draft, categories: categories, append: "\n\n That's been everything!", number_link_builder: number_link_builder, user_link_builder: user_link_builder)
        }.to raise_error(/Appended text is not present in the draft/)
      end
    end
  end

  describe '#add' do
    context 'empty draft' do
      let(:draft) { Solidus::ReleaseDrafter::Draft.empty }

      it 'adds entry under all matching categories' do
        builder = described_class.new(draft: draft, categories: categories, number_link_builder: number_link_builder, user_link_builder: user_link_builder)

        expect(
          builder.add(title: 'New entry', number: 10, user: 'alice', categories: [core, api]).content
        ).to eq <<~TXT.chomp
          ## Solidus Core
          #{entry.('New entry', 10, 'alice')}

          ## Solidus Backend


          ## Solidus API
          #{entry.('New entry', 10, 'alice')}
        TXT
      end

      it "returns the initial draft when categories don't match" do
        builder = described_class.new(draft: draft, categories: categories, number_link_builder: number_link_builder, user_link_builder: user_link_builder)

        expect(
          builder.add(title: 'New entry', number: 10, user: 'alice', categories: ['unknown']).content
        ).to eq <<~TXT.chomp
          ## Solidus Core


          ## Solidus Backend


          ## Solidus API

        TXT
      end

      it "returns the same when categories are empty" do
        builder = described_class.new(draft: draft, categories: categories, number_link_builder: number_link_builder, user_link_builder: user_link_builder)

        expect(
          builder.add(title: 'New entry', number: 10, user: 'alice', categories: []).content
        ).to eq <<~TXT.chomp
          ## Solidus Core


          ## Solidus Backend


          ## Solidus API

        TXT
      end

      it 'prepends given text' do
        builder = described_class.new(draft: draft, categories: categories, prepend: "## List of changes\n\n", number_link_builder: number_link_builder, user_link_builder: user_link_builder)

        expect(
          builder.add(title: 'New entry', number: 10, user: 'alice', categories: [core, api]).content
        ).to eq <<~TXT.chomp
          ## List of changes

          ## Solidus Core
          #{entry.('New entry', 10, 'alice')}

          ## Solidus Backend


          ## Solidus API
          #{entry.('New entry', 10, 'alice')}
        TXT
      end

      it 'appends given text' do
        builder = described_class.new(draft: draft, categories: categories, append: "\n\nThat's been everything!", number_link_builder: number_link_builder, user_link_builder: user_link_builder)

        expect(
          builder.add(title: 'New entry', number: 10, user: 'alice', categories: [core, backend]).content
        ).to eq <<~TXT.chomp
          ## Solidus Core
          #{entry.('New entry', 10, 'alice')}

          ## Solidus Backend
          #{entry.('New entry', 10, 'alice')}

          ## Solidus API


          That's been everything!
        TXT
      end
    end

    context 'existing draft' do
      it 'adds entry under all matching categories' do
        content = <<~TXT.chomp
          ## Solidus Core
          #{entry.('Old entry 1', 9, 'bob')}

          ## Solidus Backend


          ## Solidus API
          #{entry.('Old entry 2', 8, 'bob')}
        TXT
        draft = Solidus::ReleaseDrafter::Draft.new(url: 'https://release.com', content: content)
        builder = described_class.new(draft: draft, categories: categories, number_link_builder: number_link_builder, user_link_builder: user_link_builder)

        expect(
          builder.add(title: 'New entry', number: 10, user: 'alice', categories: [core, backend]).content
        ).to eq <<~TXT.chomp
          ## Solidus Core
          #{entry.('Old entry 1', 9, 'bob')}
          #{entry.('New entry', 10, 'alice')}

          ## Solidus Backend
          #{entry.('New entry', 10, 'alice')}

          ## Solidus API
          #{entry.('Old entry 2', 8, 'bob')}
        TXT
      end

      it "returns the same when categories don't match" do
        content = <<~TXT.chomp
          ## Solidus Core
          #{entry.('Old entry 1', 9, 'bob')}

          ## Solidus Backend


          ## Solidus API
          #{entry.('Old entry 2', 8, 'alice')}
        TXT
        draft = Solidus::ReleaseDrafter::Draft.new(url: 'https://release.com', content: content)
        builder = described_class.new(draft: draft, categories: categories, number_link_builder: number_link_builder, user_link_builder: user_link_builder)

        expect(
          builder.add(title: 'New entry', number: 10, user: 'alice', categories: ['unknown']).content
        ).to eq(content)
      end

      it "returns the same when categories are empty" do
        content = <<~TXT.chomp
          ## Solidus Core
          #{entry.('Old entry 1', 9, 'bob')}

          ## Solidus Backend


          ## Solidus API
          #{entry.('Old entry 2', 8, 'alice')}
        TXT
        draft = Solidus::ReleaseDrafter::Draft.new(url: 'https://release.com', content: content)
        builder = described_class.new(draft: draft, categories: categories, number_link_builder: number_link_builder, user_link_builder: user_link_builder)

        expect(
          builder.add(title: 'New entry', number: 10, user: 'alice', categories: []).content
        ).to eq(content)
      end

      it 'removes extra lines with only space characters' do
        content = <<~TXT.chomp

          ## Solidus Core

          #{entry.('Old entry 1', 9, 'bob')}

          #{entry.('Old entry 2', 10, 'alice')}
          \t
          ## Solidus Backend


          ## Solidus API

        TXT
        draft = Solidus::ReleaseDrafter::Draft.new(url: 'https://release.com', content: content)
        builder = described_class.new(draft: draft, categories: categories, number_link_builder: number_link_builder, user_link_builder: user_link_builder)

        expect(
          builder.add(title: 'New entry', number: 11, user: 'alice', categories: [core, backend]).content
        ).to eq <<~TXT.chomp
          ## Solidus Core
          #{entry.('Old entry 1', 9, 'bob')}
          #{entry.('Old entry 2', 10, 'alice')}
          #{entry.('New entry', 11, 'alice')}

          ## Solidus Backend
          #{entry.('New entry', 11, 'alice')}

          ## Solidus API

        TXT
      end

      it 'removes unknown content before categories' do
        content = <<~TXT.chomp
          Outlier
          ## Solidus Core
          #{entry.('Old entry 1', 9, 'bob')}

          ## Solidus Backend


          ## Solidus API
          #{entry.('Old entry 2', 8, 'alice')}
        TXT
        draft = Solidus::ReleaseDrafter::Draft.new(url: 'https://release.com', content: content)
        builder = described_class.new(draft: draft, categories: categories, number_link_builder: number_link_builder, user_link_builder: user_link_builder)

        expect(
          builder.add(title: 'New entry', number: 10, user: 'alice', categories: [core]).content
        ).to eq <<~TXT.chomp
          ## Solidus Core
          #{entry.('Old entry 1', 9, 'bob')}
          #{entry.('New entry', 10, 'alice')}

          ## Solidus Backend


          ## Solidus API
          #{entry.('Old entry 2', 8, 'alice')}
        TXT
      end

      it 'keeps unknown content within a category' do
        content = <<~TXT.chomp
          ## Solidus Core
          #{entry.('Old entry 1', 9, 'bob')}
          Outlier

          ## Solidus Backend


          ## Solidus API
          #{entry.('Old entry 2', 8, 'alice')}
        TXT
        draft = Solidus::ReleaseDrafter::Draft.new(url: 'https://release.com', content: content)
        builder = described_class.new(draft: draft, categories: categories, number_link_builder: number_link_builder, user_link_builder: user_link_builder)

        expect(
          builder.add(title: 'New entry', number: 10, user: 'alice', categories: [core]).content
        ).to eq <<~TXT.chomp
          ## Solidus Core
          #{entry.('Old entry 1', 9, 'bob')}
          Outlier
          #{entry.('New entry', 10, 'alice')}

          ## Solidus Backend


          ## Solidus API
          #{entry.('Old entry 2', 8, 'alice')}
        TXT
      end

      it 'keeps prepended text in place' do
        content = <<~TXT.chomp
          ## List of changes

          ## Solidus Core
          #{entry.('Old entry 1', 9, 'bob')}

          ## Solidus Backend

          ## Solidus API
          #{entry.('Old entry 2', 8, 'alice')}
        TXT
        draft = Solidus::ReleaseDrafter::Draft.new(url: 'https://release.com', content: content)
        builder = described_class.new(draft: draft, categories: categories, prepend: "## List of changes\n\n", number_link_builder: number_link_builder, user_link_builder: user_link_builder)

        expect(
          builder.add(title: 'New entry', number: 10, user: 'alice', categories: [core, api]).content
        ).to eq <<~TXT.chomp
          ## List of changes

          ## Solidus Core
          #{entry.('Old entry 1', 9, 'bob')}
          #{entry.('New entry', 10, 'alice')}

          ## Solidus Backend


          ## Solidus API
          #{entry.('Old entry 2', 8, 'alice')}
          #{entry.('New entry', 10, 'alice')}
        TXT
      end

      it 'keeps appended text in place' do
        content = <<~TXT.chomp
          ## Solidus Core
          #{entry.('Old entry 1', 9, 'bob')}

          ## Solidus Backend

          ## Solidus API
          #{entry.('Old entry 2', 8, 'alice')}

          That's been everything!
        TXT
        draft = Solidus::ReleaseDrafter::Draft.new(url: 'https://release.com', content: content)
        builder = described_class.new(draft: draft, categories: categories, append: "\n\nThat's been everything!", number_link_builder: number_link_builder, user_link_builder: user_link_builder)

        expect(
          builder.add(title: 'New entry', number: 10, user: 'alice', categories: [backend]).content
        ).to eq <<~TXT.chomp
          ## Solidus Core
          #{entry.('Old entry 1', 9, 'bob')}

          ## Solidus Backend
          #{entry.('New entry', 10, 'alice')}

          ## Solidus API
          #{entry.('Old entry 2', 8, 'alice')}

          That's been everything!
        TXT
      end
    end
  end
end
