require 'spec_helper'

describe Solidus::State, :type => :model do
  it "can find a state by name or abbr" do
    state = create(:state, :name => "California", :abbr => "CA")
    expect(Solidus::State.find_all_by_name_or_abbr("California")).to include(state)
    expect(Solidus::State.find_all_by_name_or_abbr("CA")).to include(state)
  end

  it "can find all states group by country id" do
    state = create(:state)
    expect(Solidus::State.states_group_by_country_id).to eq({ state.country_id.to_s => [[state.id, state.name]] })
  end
end
