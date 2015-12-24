require 'factory_girl'

Spree::Zone.class_eval do
  def self.global
    find_by(name: 'GlobalZone') || FactoryGirl.create(:global_zone)
  end
end

Dir["#{File.dirname(__FILE__)}/factories/**"].each do |f|
  require File.expand_path(f)
end
