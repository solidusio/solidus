# frozen_string_literal: true

class RenameBogusGateways < ActiveRecord::Migration[5.0]
  # This migration was only performing a data migration useful updating to
  # Solidus v2.3.
  # Once the update is done, this is no more required to run so we can clean
  # this file to just be a noop.
  # For more info on the original content see:
  # https://github.com/solidusio/solidus/pull/2001

  def up
    # no-op
  end

  def down
    # no-op
  end
end
