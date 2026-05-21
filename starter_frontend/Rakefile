require 'rake/clean'

::CLOBBER.include "#{__dir__}/sandbox"

task :spec do
  require 'bundler'
  Bundler.with_unbundled_env { sh 'bin/rails spec' }
end

task default: :spec
