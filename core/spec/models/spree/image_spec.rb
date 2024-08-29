# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::Image, type: :model do
  include ImageSpecHelper

  it_behaves_like "an attachment" do
    subject { create(:image) }
    let(:attachment_name) { :attachment }
    let(:default_style) { :product }
  end

  it "is valid when attachment has allowed content type" do
    image = build(:image, attachment: open_image("blank.jpg"))
    expect(image).to be_valid
  end

  it "is not valid when attachment has restricted content type" do
    image = build(:image, attachment: open_image("file.txt"))
    expect(image).to_not be_valid
  end

  describe "attachment details" do
    let(:image_file) { open_image("blank.jpg") }
    subject { create(:image, attachment: image_file) }

    it "returns if attachment is present" do
      expect(subject.attachment_present?).to be_truthy
    end

    it "returns attachment filename" do
      expect(subject.filename).to end_with("blank.jpg")
    end

    it "returns attachment url" do
      ActiveStorage::Current.url_options = {host: "https://www.example.com"}

      expect(subject.url(:product)).to include("blank.jpg")
    end

    it "computes attachment width" do
      expect(subject.attachment_width).to eq(1)
    end

    it "computes attachment height" do
      expect(subject.attachment_height).to eq(1)
    end
  end
end
