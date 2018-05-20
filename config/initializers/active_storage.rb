Rails.application.configure do
  config.active_storage.previewers << GhostscriptPreviewer
  config.active_storage.paths[:libreoffice] = '/usr/local/bin/gs'
end
