# frozen_string_literal: true

require "spec_helper"
require "rake"

describe "Load samples" do
  it "doesn't raise any error" do
    expect do
      pid = fork { Spree::Core::Engine.load_seed }
      Process.wait(pid)
      SpreeSample::Engine.load_samples
    ensure
      Process.kill(:KILL, pid) unless $?.exitstatus.zero?
    end.not_to raise_error
  end

  it "has db:seed as a prerequisite" do
    Rails.application.load_tasks

    task = Rake::Task["spree_sample:load"]
    seed_task = Rake::Task["db:seed"]
    expect(task.prerequisite_tasks).to include(seed_task)
  end
end

describe "Load seeds multiple times" do
  it "doesn't duplicate records" do
    4.times do
      pid = fork { Spree::Core::Engine.load_seed }
      Process.wait(pid)
    ensure
      Process.kill(:KILL, pid) unless $?.exitstatus.zero?
    end

    expect(Spree::Store.count).to eq(1)
    expect(Spree::Zone.count).to eq(2)
  end
end
