# frozen_string_literal: true

# This is a dummy task used for generic rake task testing

task dummy_task: :environment do
  DummyTaskRunner.run
end

class DummyTaskRunner
  def self.run
  end
end
