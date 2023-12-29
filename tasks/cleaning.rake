# frozen_string_literal: true

require 'rake/clean'

CLOBBER.include "sandbox"
CLOBBER.include "Gemfile.lock"
CLOBBER.include "{*/,}pkg"
