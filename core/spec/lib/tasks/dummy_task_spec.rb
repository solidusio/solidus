# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'dummy_task' do
  include_context(
    'rake',
    task_name: 'dummy_task',
    task_path: Spree::Core::Engine.root.join('spec/lib/tasks/dummy_task.rake'),
  )

  it 'calls the dummy task exactly once' do
    expect(DummyTaskRunner).to receive(:run).once
    task.invoke
  end

  # This tests:
  #   1) that tasks get reenabled between examples
  #   2) that tasks aren't loaded in the wrong way, causing them to execute
  #      an extra time for every example that's defined.
  # We need at least two specs to trigger the error conditions and spec order is
  # random so we just create the same spec twice. We could probably combine this
  # with the generic spec above but this seems clearer.
  2.times do |i|
    it "still calls the dummy task exactly once when more than one example is defined - #{i}" do
      expect(DummyTaskRunner).to receive(:run).once
      task.invoke
    end
  end
end
