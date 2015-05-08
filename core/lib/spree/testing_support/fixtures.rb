require 'factory_girl'

class Spree::Fixtures
  # Share a comman instance of the fixture set
  def self.instance
    @instance ||= new
  end

  # Clear out references to existing fixtures.
  # Note: This does not destroy the records from the database. It assumes you
  # have already reset the database yourself.
  def self.reset
    @instance = new
  end

  # stock location fixtures
  def stock_locations
    @stock_locations ||= StockLocations.new
  end

  # zone fixtures
  def zones
    @zones ||= Zones.new
  end

  module RSpecShortcut
    # shortcut syntax for specs: `fixtures.stock_locations.default`
    def fixtures
      Spree::Fixtures.instance
    end
  end

  private

  class StockLocations
    def default
      @default ||= Spree::StockLocation.find_by(code: 'default')
      @default ||= FactoryGirl.create(:stock_location, code: 'default')
    end
  end

  class Zones
    def global
      @global ||= Spree::Zone.find_by(name: 'global')
      @global ||= FactoryGirl.create(:global_zone, name: 'global')
    end
  end
end

RSpec.configure do |config|
  config.include Spree::Fixtures::RSpecShortcut

  config.before(:each) do
    Spree::Fixtures.reset
  end
end
