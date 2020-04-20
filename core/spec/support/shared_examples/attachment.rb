# frozen_string_literal: true

RSpec.shared_examples 'an attachment' do
  context 'valid attachment' do
    before do
      subject.send(
        :"#{attachment_name}=",
        File.open(File.join('spec', 'fixtures', 'thinking-cat.jpg'))
      )
    end

    it 'passes validations' do
      expect(subject).to be_valid
    end

    it 'returns definition' do
      expect(subject.class.attachment_definitions[attachment_name])
        .to include(default_style: default_style)
    end

    it 'returns if present' do
      expect(subject.send(:"#{attachment_name}_present?")).to be_truthy
    end

    it 'returns an actual attachment' do
      expect(subject.send(attachment_name)).to respond_to(
        :url,
        :exists?
      )
    end
  end

  context 'invalid attachment' do
    it 'fails validation' do
      invalid_file = File.open(__FILE__)
      subject.send(:"#{attachment_name}=", invalid_file)

      expect(subject).not_to be_valid
      expect(subject.errors).to include(attachment_name)
    end
  end
end
