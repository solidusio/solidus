# encoding: utf-8

require 'spec_helper'

describe "Russian errors translations" do
  def translation(count)
    Spree.t(:errors_prohibited_this_record_from_being_saved, :count => count)
  end

  context "when current locale is Russian" do
    it "translation is available" do
      I18n.locale = :ru
      translation(1).should == "1 ошибка не позволяет сохранить запись в базе"
      translation(3).should == "3 ошибки не позволяют сохранить запрос в базе"
      translation(10).should == "10 ошибок не позволяют сохранить запись в базе"
    end
  end
end
