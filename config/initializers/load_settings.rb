# Set environment variables from database
UserConfiguration.all.each do |setting|
  next unless ENV["#{setting.abbreviation.upcase}"].nil?
  
  ENV["#{setting.abbreviation.upcase}"] = "#{setting.value}"
  Rails.logger.info "ENV['#{setting.abbreviation.upcase}'] = '#{setting.value}'"
end