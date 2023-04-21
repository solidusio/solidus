# frozen_string_literal: true

require 'solidus/pipeline_context'

RSpec.describe Solidus::PipelineContext do
  describe '#initialize' do
    it 'ignores tags that do not match a full stable version number' do
      context = described_class.new(
        tags: %w[v3.0.0 v3.0 v3.0 v3 v3.0.0.beta invalid v.3.0.0],
        base_branch: 'master'
      )

      expect(context.tags).to eq(['v3.0.0'])
    end

    it 'raises when tags is empty' do
      expect {
        described_class.new(tags: [], base_branch: 'master')
      }.to raise_error(ArgumentError, 'tags cannot be empty')
    end

    it 'raises when branch is not the main one and tracks major is true' do
      expect {
        described_class.new(tags: %w[v3.0.0], base_branch: 'v3.1', tracking_major: true)
      }.to raise_error(ArgumentError, 'branch v3.1 cannot track major version')
    end

    it 'raises when branch is not the main one and tracks last minor is true' do
      expect {
        described_class.new(tags: %w[v3.0.0], base_branch: 'v3.1', last_minor: true, tracking_major: false)
      }.to raise_error(ArgumentError, 'branch v3.1 cannot track a last minor release')
    end
  end

  describe '#current_tag' do
    context 'when the base branch is the main branch' do
      it 'returns the highest tag' do
        context = described_class.new(
          tags: %w[v1.0.0 v1.0.1 v1.1.0 v2.0.0 v2.0.1 v2.0.2 v3.0.0],
          base_branch: 'master'
        )

        expect(context.current_tag).to eq('v3.0.0')
      end

      it 'compares tags as versions' do
        context = described_class.new(
          tags: %w[v1.0.0 v1.0.1 v1.1.0 v2.0.0 v3.0.0.alpha v3.0.0],
          base_branch: 'master'
        )

        expect(context.current_tag).to eq('v3.0.0')
      end
    end

    context 'when the base branch is a patch branch' do
      it 'returns the highest tag matching the base branch' do
        context = described_class.new(
          tags: %w[v1.0.0 v1.0.1 v1.1.0 v2.0.0 v2.0.1 v2.0.2 v3.0.0],
          base_branch: 'v2.0',
          tracking_major: false
        )

        expect(context.current_tag).to eq('v2.0.2')
      end

      it 'compares tags as versions' do
        context = described_class.new(
          tags: %w[v1.0.0 v1.0.1 v1.1.0 v2.0.0.alpha v2.0.0 v3.0.0],
          base_branch: 'v2.0',
          tracking_major: false
        )

        expect(context.current_tag).to eq('v2.0.0')
      end
    end
  end

  describe '#current_diff_source_tag' do
    context 'when the base branch is the main branch' do
      it 'returns the current tag adjusted to its first patch version' do
        context = described_class.new(
          tags: %w[v1.0.0 v1.0.1 v1.1.0 v2.0.0 v2.0.1 v2.0.2 v3.0.0 v3.0.1],
          base_branch: 'master'
        )

        expect(context.current_diff_source_tag).to eq('v3.0.0')
      end
    end

    context 'when the base branch is a patch branch' do
      it 'returns the current tag' do
        context = described_class.new(
          tags: %w[v1.0.0 v1.0.1 v1.1.0 v2.0.0 v2.0.1 v2.0.2 v3.0.0 v3.0.1],
          base_branch: 'v3.0',
          tracking_major: false
        )

        expect(context.current_diff_source_tag).to eq('v3.0.1')
      end
    end
  end

  describe '#candidate_tag' do
    context 'when the base branch is a patch branch' do
      it 'returns the next patch level tag on the base branch' do
        context = described_class.new(
          tags: %w[v1.0.0 v1.0.1 v1.1.0 v2.0.0 v2.0.1 v2.0.2],
          base_branch: 'v2.0',
          tracking_major: false
        )

        expect(context.candidate_tag).to eq('v2.0.3')
      end
    end

    context 'when the base branch is the main branch' do
      it "returns the next minor level tag when not tracking a major release" do
        context = described_class.new(
          tags: %w[v1.0.0 v1.0.1 v1.1.0 v2.0.0 v2.0.1 v2.0.2],
          base_branch: 'master',
          tracking_major: false
        )

        expect(context.candidate_tag).to eq('v2.1.0')
      end

      it "returns the next major level tag when tracking a major release" do
        context = described_class.new(
          tags: %w[v1.0.0 v1.0.1 v1.1.0 v2.0.0 v2.0.1 v2.0.2],
          base_branch: 'master',
          tracking_major: true
        )

        expect(context.candidate_tag).to eq('v3.0.0')
      end
    end
  end

  describe '#candidate_patch_branch' do
    it 'returns the candidate tag without the patch level' do
      context = described_class.new(
        tags: %w[v1.0.0 v1.0.1 v1.1.0 v2.0.0 v2.0.1 v2.0.2],
        base_branch: 'master',
        tracking_major: false
      )

      expect(context.candidate_patch_branch).to eq('v2.1')
    end
  end

  describe '#candidate_version' do
    it 'returns the candidate tag without the tag prefix' do
      context = described_class.new(
        tags: %w[v1.0.0 v1.0.1 v1.1.0 v2.0.0 v2.0.1 v2.0.2],
        base_branch: 'master',
        tracking_major: false
      )

      expect(context.candidate_version).to eq('2.1.0')
    end
  end

  describe '#candidate_minor_version' do
    it 'returns the candidate version without the patch segment' do
      context = described_class.new(
        tags: %w[v1.0.0 v1.0.1 v1.1.0 v2.0.0 v2.0.1 v2.0.2],
        base_branch: 'master',
        tracking_major: false
      )

      expect(context.candidate_minor_version).to eq('2.1')
    end
  end

  describe '#next_candidate_tag' do
    context 'when the base branch is a patch branch' do
      it 'returns the next patch level version after the candidate' do
        context = described_class.new(
          tags: %w[v1.0.0 v1.0.1 v1.1.0 v2.0.0 v2.0.1 v2.0.2],
          base_branch: 'v2.0',
          tracking_major: false
        )

        expect(context.next_candidate_tag).to eq('v2.0.4')
      end
    end

    context 'when the base branch is the main branch' do
      it "returns the next minor level version after the candidate when last_minor is false" do
        context = described_class.new(
          tags: %w[v1.0.0 v1.0.1 v1.1.0 v2.0.0 v2.0.1 v2.0.2],
          base_branch: 'master',
          tracking_major: false,
          last_minor: false
        )

        expect(context.next_candidate_tag).to eq('v2.2.0')
      end

      it "returns the next major level version after the candidate when last_minor is true" do
        context = described_class.new(
          tags: %w[v1.0.0 v1.0.1 v1.1.0 v2.0.0 v2.0.1 v2.0.2],
          base_branch: 'master',
          tracking_major: false,
          last_minor: true
        )

        expect(context.next_candidate_tag).to eq('v3.0.0')
      end
    end
  end

  describe '#next_candidate_dev_version' do
    it "returns the next candidate tag without the tag prefix and with '.dev' appended" do
      context = described_class.new(
        tags: %w[v1.0.0 v1.0.1 v1.1.0 v2.0.0 v2.0.1 v2.0.2],
        base_branch: 'master',
        tracking_major: false,
        last_minor: false
      )

      expect(context.next_candidate_dev_version).to eq('2.2.0.dev')
    end
  end

  describe '.tracking_major?' do
    context 'when Spree::VERSION points to the next major release' do
      it 'returns true' do
        stub_const('Spree::VERSION', '4.0.0.alpha')

        expect(described_class.tracking_major?).to be(true)
      end
    end

    context "when Spree::VERSION doesn't point to the next major release" do
      it 'returns false' do
        stub_const('Spree::VERSION', '3.3.0.alpha')

        expect(described_class.tracking_major?).to be(false)
      end
    end
  end
end
