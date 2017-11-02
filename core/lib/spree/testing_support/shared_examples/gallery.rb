# frozen_string_literal: true

RSpec.shared_examples 'a gallery' do
  describe '#images' do
    subject { gallery.images }

    it { is_expected.to be_empty }

    context 'there are images' do
      include_context 'has multiple images'

      it 'has the associated images' do
        expect(subject.map { |picture| picture.id }).
          to match_array([first_image.id, second_image.id])
      end
    end
  end
end
