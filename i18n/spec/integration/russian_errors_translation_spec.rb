# encoding: utf-8

require 'spec_helper'

describe "Russian errors translations" do
  def translation(count)
    Spree.t(:errors_prohibited_this_record_from_being_saved, :count => count)
  end

  context "when current locale is Russian" do
    it "translation is available" do
      I18n.locale = :ru
      expect(translation(1)).to eq "1 ошибка не позволяет сохранить запись в базе"
      expect(translation(3)).to eq "3 ошибок не позволяют сохранить запись в базе"
      expect(translation(10)).to eq "10 ошибки не позволяют сохранить запрос в базе"
    end
  end
end
