# frozen_string_literal: true

namespace :solidus_admin do
  namespace :tailwindcss do
    desc 'Install Tailwind CSS on the host application'
    task :install do
      system "#{RbConfig.ruby} ./bin/rails app:template LOCATION='#{__dir__}/../solidus_admin/install_tailwindcss.rb'"
    end
  end
end
