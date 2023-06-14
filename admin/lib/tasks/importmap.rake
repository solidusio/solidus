# frozen_string_literal: true

namespace :solidus_admin do
  namespace :importmap do
    desc "Render Solidus Admin's importmap JSON"
    task json: :environment do
      puts SolidusAdmin.importmap.to_json(resolver: ActionController::Base.helpers)
    end
  end
end
