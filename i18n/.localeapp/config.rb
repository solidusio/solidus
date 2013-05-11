Localeapp.configure do |config|
  config.translation_data_directory = '.localeapp/locales'
  config.synchronization_data_file  = '.localeapp/log.yml'
  config.daemon_pid_file            = '.localeapp/localeapp.pid'
end
