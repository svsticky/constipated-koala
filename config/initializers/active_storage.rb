Rails.application.configure do
  config.active_storage.previewers << GhostscriptPreviewer
  config.active_storage.paths[:ghostscript] = '/usr/local/bin/gs'
end
