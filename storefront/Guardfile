guard :shell do
  watch %r{^templates/(.*)$} do
    system("#{__dir__}/bin/sync")
  end
end
